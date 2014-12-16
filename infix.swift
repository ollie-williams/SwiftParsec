protocol Prefix {
  func parse<T>(OperatorPrecedence<T>, CharStream) -> T?
}

enum Associativity {
  case Left
  case Right
}

class Infix<T> {
  typealias Impl = (OperatorPrecedence<T>, CharStream, T) -> T?

  let ass: Associativity
  let prec: Int
  let impl: Impl

  init(ass:Associativity, prec:Int, impl:Impl) {
    self.ass = ass
    self.prec = prec
    self.impl = impl
  }

  func parse(op:OperatorPrecedence<T>, stream:CharStream, lft:T) -> T? {
    return impl(op, stream, lft)
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
    let lft = Term(stream)!
    if let ifx = GetInfix(stream) {
      return ifx.parse(self, stream:stream, lft:lft)
    }
    return lft
  }

  func addInfix(name:String, _ ifx:Infix<T>) {
    infixParsers[name] = ifx
  }

  private func GetInfix(stream:CharStream) -> Infix<T>? {
    if let str = infixFormat(stream) {
      return infixParsers[str]
    }
    return nil
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
