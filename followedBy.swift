class FollowedBy<T1 : Parser, T2 : Parser> {
  let first : T1
  let second: T2

  init(first:T1, second:T2) {
    self.first = first
    self.second = second
  }

  typealias R1 = T1.TargetType
  typealias R2 = T2.TargetType

  func parseBoth<S: CharStream>(stream: S) -> Result<(R1,R2), S> {
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

class FollowedByBoth<T1 : Parser, T2 : Parser> : FollowedBy<T1,T2>, Parser {
  typealias TargetType = (R1,R2)
  override init(first:T1, second:T2) {
    super.init(first:first, second:second)
  }
  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    return parseBoth(stream)
  }
}

class FollowedByFirst<T1 : Parser, T2 : Parser> : FollowedBy<T1,T2>, Parser {
  typealias TargetType = R1
  override init(first:T1, second:T2) {
    super.init(first:first, second:second)
  }
  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    switch parseBoth(stream) {
      case .Failure(let str, let msg):
        return Result(stream: str.item, msg: msg)
      case .Success(let vals, let str):
        let (val, _) = vals.item
        return Result(value: val, stream: str.item)
    }
  }
}

class FollowedBySecond<T1 : Parser, T2 : Parser> : FollowedBy<T1,T2>, Parser {
  typealias TargetType = R2
  override init(first:T1, second:T2) {
    super.init(first:first, second:second)
  }
  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    switch parseBoth(stream) {
      case .Failure(let str, let msg):
        return Result(stream: str.item, msg: msg)
        case .Success(let vals, let str):
          let (_, val) = vals.item
          return Result(value: val, stream: str.item)
        }
      }
    }


infix operator >> {associativity left precedence 140}
func >><T1: Parser, T2: Parser>(first: T1, second: T2) -> FollowedByBoth<T1,T2> {
  return FollowedByBoth(first: first, second: second)
}

infix operator ->> {associativity left precedence 140}
func ->><T1: Parser, T2: Parser>(first: T1, second: T2) -> FollowedByFirst<T1,T2> {
  return FollowedByFirst(first: first, second: second)
}

infix operator >>- {associativity left precedence 140}
func >>-<T1: Parser, T2: Parser>(first: T1, second: T2) -> FollowedBySecond<T1,T2> {
  return FollowedBySecond(first: first, second: second)
}
