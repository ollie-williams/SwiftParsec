let source = "HelloWorld"
let cnst1 = const("Hello")
let cnst2 = const("World")
let parser = cnst1 >>- cnst2
let result = source |> parser
println(result)

func function(s:String) -> Int { return countElements(s) }
let parser2 = pipe(parser, function)
let result2 = source |> parser2
println(result2)

let result3 = "HelloHelloHelloWorld" |> many(const("Hello")) >>- const("World")
println(result3)

class Expr {
  let symbol  : String
  let children: [Expr]

  init(symbol:String, children:[Expr]) {
    self.symbol = symbol
    self.children = children
  }
}

func idChar(c:Character) -> Bool {
  switch c {
    case "(", ")", " ":
      return false
    default:
      return true
  }
}
let identifier = many1chars(satisfy(idChar))

let result4 = "fooble_barble" |> identifier
println(result4)

/*
let fnCall = "(" >>- pipe2(identifier, many(expr)) ->> ")"
let solo = identifier

func lispParser(s:String) -> Expr {
  return Expr(
    symbol: "f",
    children: []
  )
}
*/
