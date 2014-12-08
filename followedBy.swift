class FollowedBy<T1 : Parser, T2 : Parser> : Parser {
  let first : T1
  let second: T2

  init(first:T1, second:T2) {
    self.first = first
    self.second = second
  }

  typealias R1 = T1.TargetType
  typealias R2 = T2.TargetType
  typealias TargetType = (R1,R2)

  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    switch first.parse(stream) {
      case .Failure(_, let msg):
        return Result(stream: stream, msg: msg)
      case .Success(let fst, let str1):
        switch second.parse(str1.item) {
          case .Failure(_, let msg):
            return Result(stream: stream, msg: msg)
          case .Success(let snd, let str2):
            return Result(
              value : (fst.item, snd.item),
              stream: str2.item
            )
        }
    }
  }
}

infix operator >> {associativity left precedence 140}
func >><T1: Parser, T2: Parser>(first: T1, second: T2) -> FollowedBy<T1,T2> {
  return FollowedBy(first: first, second: second)
}
