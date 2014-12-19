import Cocoa

class Integer : Parser {
  typealias Target = Int

  func parse(stream:CharStream) -> Int? {
    let regex = "[+-]?[0-9]+"
    if let match = stream.startsWithRegex(regex) {
      stream.advance(countElements(match))
      return match.toInt()
    }
    return nil
  }
}

func stringToFloat(str:String) -> Double {
  return (str as NSString).doubleValue
}
class FloatParser : Parser {
  typealias Target = Double

  private let strict:Bool

  // class variables not yet supported
  private /*class*/ let impl
      = pipe(regex("[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?"), stringToFloat)

  init(strict:Bool) {
    self.strict = strict
  }

  func parse(stream:CharStream) -> Target? {
    if !strict {
      return impl.parse(stream)
    }

    let start = stream.pos
    if let ip = Integer().parse(stream) {
      let intend = stream.pos
      stream.pos = start
      if let fp = impl.parse(stream) {
        if stream.pos == intend {
          return nil
        }
        return fp
      }
    }
    return impl.parse(stream)
  }

}
