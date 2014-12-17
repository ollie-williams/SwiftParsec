class Prefix<T> {
  func parse(opp:OperatorPrecedence<T>, _ stream:CharStream) -> T? {
    return nil
  }
}

enum Associativity {
  case Left
  case Right
}

class Infix<T> {
  typealias Builder = (T, T) -> T?

  let ass: Associativity
  let prec: Int
  let build: Builder

  init(ass:Associativity, _ prec:Int, _ build:Builder) {
    self.ass = ass
    self.prec = prec
    self.build = build
  }

  func parse(opp:OperatorPrecedence<T>, _ stream:CharStream, _ lft:T) -> T? {
    if let rgt = opp.parse(stream, prec, ass) {
      return build(lft, rgt)
    }
    return nil
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
    if let str = pattern(stream) {
      return dict[str]
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

  private let infixOps:OpSet<Infix<T>>
  private let prefixOps:OpSet<Prefix<T>>
  var term: ParseFunc?

  init(opFormat: CharStream -> String?) {
    infixOps = OpSet<Infix<T>>(opFormat)
    prefixOps = OpSet<Prefix<T>>(opFormat)
    term = nil
  }

  func parse(stream:CharStream) -> T? {
    return parse(stream, 0, .Left)
  }

  func parse(stream:CharStream, var _ prec:Int, _ ass:Associativity) -> T? {
    var lft = Term(stream)!
    if ass == .Right {
      prec = prec - 1
    }
    while let ifx = infixOps.get(stream) {
      if ifx.prec > prec {
        lft = ifx.parse(self, stream, lft)!
      } else {
        infixOps.putBack(ifx)
        break
      }
    }
    return lft
  }

  func addInfix(name:String, _ ifx:Infix<T>) {
    infixOps.dict[name] = ifx
  }

  private func Term(stream:CharStream) -> T? {
    if let tp = term {
      return tp(stream)
    }
    return nil
  }
}
