protocol Prefix {
  func parse<T>(OperatorPrecedence<T>, CharStream) -> T?
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

class OperatorPrecedence<T> : Parser {
  typealias Target = T
  typealias ParseFunc  = CharStream -> T?

  let infixFormat: CharStream -> String?

  var term: ParseFunc?
  var infixParsers: [String:Infix<T>]

  init(infixFormat: CharStream -> String?) {
    self.infixFormat = infixFormat
    term = nil
    infixParsers = [:]
  }

  func parse(stream:CharStream) -> T? {
    return parse(stream, 0, .Left)
  }

  func parse(stream:CharStream, var _ prec:Int, _ ass:Associativity) -> T? {
    var lft = Term(stream)!
    if ass == .Right {
      prec = prec - 1
    }
    while let ifx = GetInfix(stream) {
      if ifx.prec > prec {
        lft = ifx.parse(self, stream, lft)!
      } else {
        putBack(ifx)
        break
      }
    }
    return lft
  }

  func addInfix(name:String, _ ifx:Infix<T>) {
    infixParsers[name] = ifx
  }

  var next:Infix<T>?

  private func GetInfix(stream:CharStream) -> Infix<T>? {
    if let ifx = next {
      next = nil
      return ifx
    }
    if let str = infixFormat(stream) {
      return infixParsers[str]
    }
    return nil
  }

  private func putBack(ifx:Infix<T>) -> Void {
    assert(next == nil, "Expected cache to be empty.")
    next = ifx
  }

  private func GetPrefix(stream:CharStream) -> Prefix? {
    return nil
  }

  private func Term(stream:CharStream) -> T? {
    if let tp = term {
      return tp(stream)
    }
    return nil
  }
}
