import Foundation

//---------------------------------//
// Inputs
//---------------------------------//
class CharStream {
  let str: String
  var pos: String.Index

  init(str: String) {
    self.str = str
    self.pos = str.startIndex
  }

  var head:Character? {
    get {
      if pos < str.endIndex {
        return str[pos]
      }
      return nil
    }
  }

  var position:String.Index {
    get {
      return pos
    }
    set {
      pos = newValue
    }
  }

  var eof:Bool {
    get {
      return pos == str.endIndex
    }
  }

  func startsWith(query: String) -> Bool {
    return str.substringFromIndex(pos).hasPrefix(query)
  }

  func startsWithRegex(pattern: String) -> String? {
    if let range = str.rangeOfString(
      pattern,
      options: [.RegularExpressionSearch, .AnchoredSearch],
      range: pos..<str.endIndex,
      locale: nil) {
      return str.substringWithRange(range)
    }
    return nil
  }

  func advance(count: Int) -> Void {
    pos = pos.advancedBy(count)
  }

  func error(msg: String) -> Void {}
}
