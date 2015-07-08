class LateBound<T>: Parser {
  typealias Target = T
  typealias ParseFunc  = CharStream -> T?

  var inner: ParseFunc?

  init() {}

  func parse(stream:CharStream) -> T? {
    if let impl = inner {
      return impl(stream)
    }
    fatalError("No inner implementation was provided for late-bound parser.")    
  }
}
