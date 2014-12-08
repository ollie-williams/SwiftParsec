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


class Pipe2<T1:Parser, T2:Parser, V> : Parser {
  typealias TargetType = V
  typealias R1 = T1.TargetType
  typealias R2 = T2.TargetType

  let first: T1
  let second: T2
  let fn: (R1, R2) -> V

  init(first:T1, second:T2, fn: (R1, R2) -> V) {
    self.first = first
    self.second = second
    self.fn = fn
  }

  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    let fb = FollowedBy(first:first, second:second)
    switch fb.parseBoth(stream) {
      case .Success(let vals, let str):
        let (a,b) = vals.item
        return Result(
          value : fn(a, b),
          stream: str.item
          )
        case .Failure(let str, let msg):
          return Result(stream:str.item, msg:msg)
    }
  }

}
