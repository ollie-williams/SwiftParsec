class Alternates<T1:Parser, T2:Parser where T1.TargetType==T2.TargetType> : Parser {
  typealias TargetType = T1.TargetType

  let first : T1
  let second: T2

  init(first: T1, second: T2) {
    self.first = first
    self.second = second
  }

  func parse<S:CharStream>(inout stream:S) -> TargetType? {
    if let fst = first.parse(&stream) {
      return fst
    }
    if let snd = second.parse(&stream) {
      return snd
    }
    return nil
  }
}

func | <T1:Parser, T2:Parser where T1.TargetType==T2.TargetType>(
    first : T1,
    second: T2) ->
    Alternates<T1,T2> {
  return Alternates(first:first, second:second)
}
