class Pipe<T:Parser, V> : Parser {
  typealias TargetType = V
  typealias R = T.TargetType

  let parser: T
  let fn    : R -> V

  init(inner: T, fn: R -> V) {
    self.parser = inner
    self.fn = fn
  }

  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    switch parser.parse(stream) {
      case .Success(let value, let str):
        return Result(
          value : fn(value.item),
          stream: str.item
          )
      case .Failure(let str, let msg):
        return Result(stream: str.item, msg: msg)
    }
  }
}
