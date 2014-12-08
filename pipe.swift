class Pipe<T:Parser, V> : Parser {
  typealias TargetType = V
  typealias R = T.TargetType

  let parser: T
  let fn    : R -> V

  init(inner: T, fn: R -> V) {
    self.parser = inner
    self.fn = fn
  }

  func parse<S: CharStream>(inout stream: S) -> TargetType? {
    if let value = parser.parse(&stream) {
      return fn(value)
    }
    return nil
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

  func parse<S: CharStream>(inout stream: S) -> TargetType? {
    let reset = stream
    if let a = first.parse(&stream) {
      if let b = second.parse(&stream) {
        return fn(a,b)
      }
    }
    stream = reset
    return nil
  }
}
