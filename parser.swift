
//---------------------------------//
// Parsing
//---------------------------------//
protocol Parser {
  typealias Target
  func parse(CharStream) -> Target?
}

infix operator |> {associativity left precedence 130}
func |> <T: Parser>(string: String, parser: T) -> T.Target? {
  var stream = CharStream(str: string)
  return parser.parse(stream)
}
