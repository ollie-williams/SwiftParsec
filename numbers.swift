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
