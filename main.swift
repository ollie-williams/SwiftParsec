let source = BasicString(str: "HelloWorld")
let cnst1 = Constant(str: "Hello")
let cnst2 = Constant(str: "World")
let parser = cnst1 >>- cnst2
var src1 = source
let result = parser.parse(&src1)
println(result)

func function(s:String) -> Int { return countElements(s) }
let parser2 = Pipe(inner:parser, fn:function)
var src2 = source
let result2 = parser2.parse(&src2)
println(result2)

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
//let identifier = many(satisfy(idChar))

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
