import Darwin
import Cocoa

//---------------------------------//
// Inputs
//---------------------------------//
protocol CharStream {
  func startsWith(String) -> Bool
  func advance(Int) -> Self
  func error(String) -> Void
}

final class BasicString : CharStream {
  let str: String

  init(str: String) {
    self.str = str
  }

  func startsWith(query: String) -> Bool {
    return str.hasPrefix(query)
  }

  func advance(count: Int) -> BasicString {
    let index = Swift.advance(str.startIndex, count)
    let substring = str.substringFromIndex(index)
    return BasicString(str: substring)
  }

  func error(msg: String) -> Void {}
}


//---------------------------------//
// Parsing
//---------------------------------//
protocol Parser {
  typealias TargetType
  func parse<S:CharStream>(inout S) -> TargetType?
}

infix operator |> {associativity left precedence 130}
func |> <T: Parser>(string: String, parser: T) -> T.TargetType? {
  var stream = BasicString(str: string)
  return parser.parse(&stream)
}
