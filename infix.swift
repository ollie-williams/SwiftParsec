protocol Prefix {
  func parse<T>(OperatorPrecedence<T>, CharStream) -> T?
}

class Infix<T> {
  typealias Impl = (OperatorPrecedence<T>, CharStream, T) -> T?
  let impl: Impl

  init(impl: Impl) {
    self.impl = impl
  }

  func parse(op:OperatorPrecedence<T>, stream:CharStream, left:T) -> T? {
    return impl(op, stream, left)
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
    // Get first term
    let left = Term(stream)!
    if let ifx = GetInfix(stream) {
      return ifx.parse(self, stream:stream, left:left)
    }
    return left
  }

  func addInfix(name:String, ifx:Infix<T>) {
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
