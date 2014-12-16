func lnprint<T>(val:T, file: String = __FILE__, line: Int = __LINE__) -> Void {
  println("\(file)(\(line)): \(val)")
}

func parse<T:Parser>(parser:T, string:String) -> T.Target? {
  var stream = CharStream(str:string)
  return parser.parse(stream)
}

let intp = Integer()
lnprint(parse(intp, "-4379wigblksl"))
lnprint(parse(intp, "925 fhsjdkfh"))
lnprint(parse(intp, "fhsjdkfh"))

let source = "HelloWorld"
let cnst1 = const("Hello")
let cnst2 = const("World")
let parser = cnst1 >~ cnst2
let result = parse(parser, source)
lnprint(result)

func function(s:String) -> Int { return countElements(s) }
let parser2 = pipe(parser, function)
let result2 = parse(parser2, source)
lnprint(result2)

let result3 =
  parse(
        many(const("Hello")) >~ const("World"),
        "HelloHelloHelloWorld"
    )
lnprint(result3)

class Expr {
  let symbol  : String
  let children: [Expr]

  init(symbol:String, children:[Expr]) {
    self.symbol = symbol
    self.children = children
  }

  class func MakeFn(symbol:String, children:[Expr]) -> Expr {
    return Expr(symbol:symbol, children:children)
  }

  class func MakeLeaf(symbol:String) -> Expr {
    return Expr(symbol:symbol, children:[])
  }
}

let skip = manychars(constchar(" "))
func idChar(c:Character) -> Bool {
  switch c {
    case "(", ")", " ":
      return false
    default:
      return true
  }
}
let identifier = many1chars(satisfy(idChar)) ~> skip

let leaf = identifier |> Expr.MakeLeaf

var expr = LateBound<Expr>()
let oparen = const("(") ~> skip
let cparen = const(")") ~> skip
let fnCall = oparen >~ pipe2(identifier, many(expr), Expr.MakeFn) ~> cparen
let choice = fnCall | leaf
expr.inner = choice.parse

func cStyle(expr:Expr) -> String {
  if expr.children.count == 0 {
    return expr.symbol
  }
  var args = cStyle(expr.children[0])
  for i in 1..<expr.children.count {
    args = args + ", " + cStyle(expr.children[i])
  }
  return "\(expr.symbol)(\(args))"
}

let sexpr = "(f (add a (g b)) a (g c))"
let result6 = parse(expr, sexpr)
println("\(sexpr) = \(cStyle(result6!))")
