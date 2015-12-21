struct Integer : Parser {
  typealias Target = Int

  static let impl = pipe(
    regex("[+-]?[0-9]+"),
    fn: {Int($0)!})

  func parse(stream:CharStream) -> Int? {
    return Integer.impl.parse(stream)
  }
}


struct FloatParser : Parser {
  typealias Target = Double

  private let strict:Bool

  static func stringToFloat(str:String) -> Double {
    if let d = Double(str) { return d }
    return Double.NaN
  }

  static let impl = pipe(
        regex("[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?"),
        fn: FloatParser.stringToFloat)

  init(strict:Bool) {
    self.strict = strict
  }

  func parse(stream:CharStream) -> Target? {
    if !strict {
      return FloatParser.impl.parse(stream)
    }

    let start = stream.pos
    if let _ = Integer().parse(stream) {
      let intend = stream.pos
      stream.pos = start
      if let fp = FloatParser.impl.parse(stream) {
        if stream.pos == intend {
          stream.pos = start
          return nil
        }
        return fp
      }
    }
    return FloatParser.impl.parse(stream)
  }
}
