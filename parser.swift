
//---------------------------------//
// Parsing
//---------------------------------//
protocol Parser {
  typealias TargetType
  func parse(inout CharStream) -> TargetType?
}

infix operator |> {associativity left precedence 130}
func |> <T: Parser>(string: String, parser: T) -> T.TargetType? {
  var stream = CharStream(str: string)
  return parser.parse(&stream)
}
