class Pipe<T:Parser, V> : Parser {
  typealias TargetType = V
  typealias R = T.TargetType

  let parser: T
  let fn    : R -> V

  init(inner: T, fn: R -> V) {
    self.parser = inner
    self.fn = fn
  }

  func parse(inout stream: CharStream) -> TargetType? {
    if let value = parser.parse(&stream) {
      return fn(value)
    }
    return nil
  }
}

func pipe<T:Parser, V>(inner: T, fn: T.TargetType -> V) -> Pipe<T,V> {
  return Pipe(inner:inner, fn:fn)
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

  func parse(inout stream: CharStream) -> TargetType? {
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

func pipe2<T1:Parser, T2:Parser, V> (
    first : T1,
    second: T2,
    fn    : (T1.TargetType, T2.TargetType) -> V
  ) -> Pipe2<T1,T2,V> {
  return Pipe2(first:first, second:second, fn:fn)
}
