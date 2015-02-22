class Many<T:Parser> : Parser {
  typealias Target = [T.Target]

  let body: T
  let emptyOk: Bool

  init(body:T, emptyOk:Bool) {
    self.body = body
    self.emptyOk = emptyOk
  }

  func parse(stream:CharStream) -> Target? {
    var result = Target()
    while let r = body.parse(stream) {
      result.append(r)
    }
    if !emptyOk && result.count == 0 {
      return nil
    }
    return result
  }
}

func many<T:Parser>(body:T) -> Many<T> {
  return Many(body:body, emptyOk:true)
}

func many1<T:Parser>(body:T) -> Many<T> {
  return Many(body:body, emptyOk:false)
}

class SepBy<T:Parser, S:Parser> : Parser {
  typealias Target = [T.Target]

  let item: T
  let sep:  S
  let pair: FollowedBySecond<S,T>

  init(item:T, sep:S) {
    self.item = item
    self.sep = sep
    self.pair = sep >~ item
  }

  func parse(stream:CharStream) -> Target? {
    var result = Target()
    if let x = item.parse(stream) {
      result.append(x)
      while let next = pair.parse(stream) {
        result.append(next)
      }
    }
    return result
  }
}

func sepby<T:Parser, S:Parser>(item:T, sep:S) -> SepBy<T,S> {
  return SepBy(item:item, sep:sep)
}
