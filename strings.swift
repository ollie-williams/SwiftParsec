class Constant : Parser {
  let str: String

  init(str:String) {
    self.str = str
  }

  typealias TargetType = String

  func parse<S: CharStream>(inout stream:S) -> TargetType? {
    if stream.startsWith(str) {
      stream = stream.advance(countElements(str))
      return str
    }
    stream.error("Expected \(str)")
    return nil
  }
}

func const(str: String) -> Constant {
  return Constant(str:str)
}
