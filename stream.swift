import Darwin
import Cocoa

//---------------------------------//
// Inputs
//---------------------------------//
class CharStream {
  let str: String

  init(str: String) {
    self.str = str
  }

  var head:Character? {
    get {
      if countElements(str) == 0 {
        return nil
      }
      return str[str.startIndex]
    }
  }

  func startsWith(query: String) -> Bool {
    return str.hasPrefix(query)
  }

  func advance(count: Int) -> CharStream {
    let index = Swift.advance(str.startIndex, count)
    let substring = str.substringFromIndex(index)
    return CharStream(str: substring)
  }

  func error(msg: String) -> Void {}
}
