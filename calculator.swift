struct Calculator {
  // Skip over whitespace
  static let skip = regex("\\s*")

  // Useful character constants
  static let oparen = const("(") ~> skip
  static let cparen = const(")") ~> skip
  static let comma = const(",") ~> skip

  // The operator precendence parser at the heart of our calculator
  static let opFormat = (regex("[+*-/%\\^]")) ~> skip
  static let opp = OperatorPrecedence<Double>(opFormat.parse)

  // Floating-point number literals
  static let flt = FloatParser(strict:false) ~> skip

  // Functions
  static let arg1 = oparen >~ opp ~> cparen
  static let sinfunc = const("sin") >~ arg1 |> sin
  static let cosfunc = const("cos") >~ arg1 |> cos
  static let tanfunc = const("tan") >~ arg1 |> tan
  static let expfunc = const("exp") >~ arg1 |> exp
  static let logfunc = const("log") >~ arg1 |> log
  static let sqrtfunc = const("sqrt") >~ arg1 |> sqrt
  static let funcs = sinfunc | cosfunc | tanfunc | expfunc | logfunc | sqrtfunc

  // A term in brackets
  static let brackets = oparen >~ opp ~> cparen

  // Parsing terms within an infix expression
  static let termParser  = funcs | brackets | flt

  // Top-level parser ensures that the whole string got processed
  static let top = opp ~> eof()

  private static func initialize() -> Void {
    if opp.term == nil {
      // Add infix operators
      opp.addOperator("+", .LeftInfix({return $0 + $1}, 50))
      opp.addOperator("-", .LeftInfix({return $0 - $1}, 50))
      opp.addOperator("*", .LeftInfix({return $0 * $1}, 70))
      opp.addOperator("/", .LeftInfix({return $0 / $1}, 70))
      opp.addOperator("%", .LeftInfix({return $0 % $1}, 70))
      opp.addOperator("^", .LeftInfix({return pow($0,$1)}, 80))

      // Add prefix operators
      opp.addOperator("+", Prefix({return +$0}, 60))
      opp.addOperator("-", Prefix({return -$0}, 60))

      // Close the loop
      opp.term = termParser.parse
    }
  }

  static func parse(stream:CharStream) -> Double? {
    initialize()
    return top.parse(stream)
  }
}
