import Cocoa

struct Integer : Parser {
  typealias Target = Int

  static let impl = pipe(
    regex("[+-]?[0-9]+"),
    {$0.toInt()!})

  func parse(stream:CharStream) -> Int? {
    return Integer.impl.parse(stream)
  }
}


struct FloatParser : Parser {
  typealias Target = Double

  private let strict:Bool

  static func stringToFloat(str:String) -> Double {
    return (str as NSString).doubleValue
  }

  static let impl = pipe(
        regex("[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?"),
        FloatParser.stringToFloat)

  init(strict:Bool) {
    self.strict = strict
  }

  func parse(stream:CharStream) -> Target? {
    if !strict {
      return FloatParser.impl.parse(stream)
    }

    let start = stream.pos
    if let ip = Integer().parse(stream) {
      let intend = stream.pos
      stream.pos = start
      if let fp = FloatParser.impl.parse(stream) {
        if stream.pos == intend {
          return nil
        }
        return fp
      }
    }
    return FloatParser.impl.parse(stream)
  }
}
