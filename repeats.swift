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
