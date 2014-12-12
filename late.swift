class LateBound<T>: Parser {
  typealias TargetType = T
  typealias ParseFunc  = CharStream -> T?

  var inner: ParseFunc?

  func parse(stream:CharStream) -> T? {
    if let impl = inner {
      return impl(stream)
    }
    fatalError("No inner implementation was provided for late-bound parser.")
    return nil
  }
}
