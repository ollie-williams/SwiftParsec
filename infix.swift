class Prefix<T> {
  typealias Builder = T -> T?

  let prec:  Int
  let build: Builder

  init(_ build:Builder, _ prec:Int) {
    self.build = build
    self.prec = prec
  }

  func parse<
    O:Parser, P:Parser
    where P.Target==T, O.Target==String>
    (opp:OperatorPrecedence<T,O,P>, _ stream:CharStream) -> T? 
  {
    if let arg = opp.parse(stream, prec) {
      return build(arg)
    }
    return nil
  }
}


enum OperatorHandler<T> {
  typealias Binary = (T, T) -> T?
  typealias Unary = T -> T?

  case Prefix(Unary, Int)
  case LeftInfix(Binary, Int)
  case RightInfix(Binary, Int)
  case Postfix(Unary, Int)

  func parse<
      O:Parser, P:Parser
      where P.Target==T, O.Target==String>
      (opp:OperatorPrecedence<T,O,P>, _ stream:CharStream, _ lft:T?) -> T? 
{
    switch self {
      case Prefix(let unary, let prec):
        assert(lft == nil, "Prefix operators don't have left hand sides.")
        if let arg = opp.parse(stream, prec) {
          return unary(arg)
        }
        break

      case LeftInfix(let binary, let prec):
        if let rgt = opp.parse(stream, prec) {
          return binary(lft!, rgt)
        }
        break

      case RightInfix(let binary, let prec):
        if let rgt = opp.parse(stream, prec-1) {
          return binary(lft!, rgt)
        }
        break

      case Postfix(let unary, _):
        return unary(lft!)
    }
    return nil
  }

  var precedence:Int {
    get {
      switch self {
        case Prefix(_, let prec): return prec
        case LeftInfix(_, let prec): return prec
        case RightInfix(_, let prec): return prec
        case Postfix(_, let prec): return prec
      }
    }
  }
}

private class OpSet<V,O:Parser where O.Target==String> {
  let pattern      : O
  var dict         : [String:V]
  private var next : V?

  init(pattern:O) {
    self.pattern = pattern
    self.dict = [:]
    self.next = nil
  }

  func get(stream:CharStream) -> V? {
    if let val = next {
      next = nil
      return val
    }
    let old = stream.pos
    if let str = pattern.parse(stream) {
      if let retval = dict[str] {
        return retval
      } else {
        // Put characters back if we don't know how to use them here:
        // either they'll be picked-up by another round of processing
        // or there's a syntax error
        stream.pos = old
      }
    }
    return nil
  }

  func putBack(val:V) -> Void {
    assert(next == nil, "Expected cache to be empty.")
    next = val
  }
}

class OperatorPrecedence<
  T, O:Parser, P:Parser 
  where P.Target==T, O.Target==String > : Parser 
{
  typealias Target = T

  private let infixOps  : OpSet<OperatorHandler<T>, O>
  private let prefixOps : OpSet<OperatorHandler<T>, O>
  private let primary   : P

  init(opFormat:O, primary:P) {
    infixOps = OpSet<OperatorHandler<T>,O>(pattern:opFormat)
    prefixOps = OpSet<OperatorHandler<T>,O>(pattern:opFormat)
    self.primary = primary
  }

  func parse(stream:CharStream) -> T? {
    return parse(stream, 0)
  }

  func parseStart(stream:CharStream) -> T? {
    if let pfx = prefixOps.get(stream) {
      return pfx.parse(self, stream, nil)
    }
    if let p = primary.parse(stream) {
      return p
    }
    return nil
  }

  func parse(stream:CharStream, _ prec:Int) -> T? {
    var lft = parseStart(stream)

    while let ifx = infixOps.get(stream) {
      if lft == nil {
        return nil
      }

      if ifx.precedence > prec {
        lft = ifx.parse(self, stream, lft!)
      } else {
        infixOps.putBack(ifx)
        break
      }
    }
    return lft
  }

  func addOperator(name:String, _ op:OperatorHandler<T>) {
    switch(op) {
      case .Prefix:
        prefixOps.dict[name] = op
        break
      default:
        infixOps.dict[name] = op
        break
    }
  }
}
