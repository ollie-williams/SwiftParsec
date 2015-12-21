class Pipe<T:Parser, V> : Parser {
  typealias Target = V
  typealias R = T.Target

  let parser: T
  let fn    : R -> V

  init(inner: T, fn: R -> V) {
    self.parser = inner
    self.fn = fn
  }

  func parse(stream: CharStream) -> Target? {
    if let value = parser.parse(stream) {
      return fn(value)
    }
    return nil
  }
}

func pipe<T:Parser, V>(inner: T, fn: T.Target -> V) -> Pipe<T,V> {
  return Pipe(inner:inner, fn:fn)
}

infix operator |> {associativity left precedence 130}
func |> <T: Parser, V>(inner: T, fn: T.Target -> V) -> Pipe<T,V> {
  return pipe(inner, fn: fn)
}


class Pipe2<T1:Parser, T2:Parser, V> : Parser {
  typealias Target = V
  typealias R1 = T1.Target
  typealias R2 = T2.Target

  let first: T1
  let second: T2
  let fn: (R1, R2) -> V

  init(first:T1, second:T2, fn: (R1, R2) -> V) {
    self.first = first
    self.second = second
    self.fn = fn
  }

  func parse(stream: CharStream) -> Target? {
    let old = stream.position
    if let a = first.parse(stream) {
      if let b = second.parse(stream) {
        return fn(a,b)
      }
    }
    stream.position = old
    return nil
  }
}

func pipe2<T1:Parser, T2:Parser, V> (
    first : T1,
    second: T2,
    fn    : (T1.Target, T2.Target) -> V
  ) -> Pipe2<T1,T2,V> {
  return Pipe2(first:first, second:second, fn:fn)
}
