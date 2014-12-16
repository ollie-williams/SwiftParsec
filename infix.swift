protocol Prefix {
  func parse<T>(OperatorPrecedence<T>, CharStream) -> T?
}

protocol Infix {
  func parse<T>(OperatorPrecedence<T>, CharStream) -> T?
}


class OperatorPrecedence<T> : Parser {
  typealias Target = T
  typealias ParseFunc  = CharStream -> T?

  var term: ParseFunc?

  init() {
    term = nil
  }

  func parse(stream:CharStream) -> T? {
    // Get first term
    let left = Term(stream)!
    if let ifx = GetInfix(stream) {
      return ifx.parse(self, stream)
    }
    return left
  }

  private func GetInfix(stream:CharStream) -> Infix? {
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
