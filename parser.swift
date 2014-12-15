
//---------------------------------//
// Parsing
//---------------------------------//
protocol Parser {
  typealias Target
  func parse(CharStream) -> Target?
}
