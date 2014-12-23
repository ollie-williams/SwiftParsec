class Prefix<T> {
  typealias Builder = T -> T?

  let prec:  Int
  let build: Builder

  init(_ build:Builder, _ prec:Int) {
    self.build = build
    self.prec = prec
  }

  func parse(opp:OperatorPrecedence<T>, _ stream:CharStream) -> T? {
    if let arg = opp.parse(stream, prec) {
      return build(arg)
    }
    return nil
  }
}


enum OperatorHandler<T> {
  typealias Binary = (T, T) -> T?
  typealias Unary = T -> T?

  case LeftInfix(Binary, Int)
  case RightInfix(Binary, Int)
  case Postfix(Unary, Int)

  func parse(opp:OperatorPrecedence<T>, _ stream:CharStream, _ lft:T) -> T? {
    switch self {
      case LeftInfix(let binary, let prec):
        if let rgt = opp.parse(stream, prec) {
          return binary(lft, rgt)
        }
        break

      case RightInfix(let binary, let prec):
        if let rgt = opp.parse(stream, prec-1) {
          return binary(lft, rgt)
        }
        break

      case Postfix(let unary, _):
        return unary(lft)
    }
    return nil
  }

  var precedence:Int {
    get {
      switch self {
        case LeftInfix(_, let prec): return prec
        case RightInfix(_, let prec): return prec
        case Postfix(_, let prec): return prec
      }
    }
  }
}

private class OpSet<V> {
  let pattern: CharStream -> String?
  var dict:    [String:V]
  var next:    V?

  init(pattern:CharStream -> String?) {
    self.pattern = pattern
    self.dict = [:]
    self.next = nil
  }

  func get(stream:CharStream) -> V? {
    if let try = next {
      next = nil
      return try
    }
    let old = stream.pos
    if let str = pattern(stream) {
      if let retval = dict[str] {
        return retval
      } else {
        // Put characters back if we don't know how to use them here:
        // either they'll be picked-up by another round of processing, or
        // there's a syntax error
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

class OperatorPrecedence<T> : Parser {
  typealias Target = T
  typealias ParseFunc  = CharStream -> T?

  private let infixOps:OpSet<OperatorHandler<T>>
  private let prefixOps:OpSet<Prefix<T>>
  var term: ParseFunc?

  init(opFormat: CharStream -> String?) {
    infixOps = OpSet<OperatorHandler<T>>(opFormat)
    prefixOps = OpSet<Prefix<T>>(opFormat)
    term = nil
  }

  func parse(stream:CharStream) -> T? {
    return parse(stream, 0)
  }

  func parseStart(stream:CharStream) -> T? {
    if let pfx = prefixOps.get(stream) {
      return pfx.parse(self, stream)
    }
    if let t = Term(stream) {
      return t
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
    infixOps.dict[name] = op
  }

  func addOperator(name:String, _ pfx:Prefix<T>) {
    prefixOps.dict[name] = pfx
  }

  private func Term(stream:CharStream) -> T? {
    if let tp = term {
      return tp(stream)
    }
    return nil
  }
}
