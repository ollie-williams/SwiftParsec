class LateBound<T>: Parser {
  typealias TargetType = T
  typealias ParseFunc  = (inout CharStream) -> T?

  func parse(inout stream:CharStream) -> T? {
    return nil
  }
}
