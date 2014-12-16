func lnprint<T>(val:T, file: String = __FILE__, line: Int = __LINE__) -> Void {
  println("\(file)(\(line)): \(val)")
}

func parse<T:Parser>(parser:T, string:String) -> T.Target? {
  var stream = CharStream(str:string)
  return parser.parse(stream)
}

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

let opp = OperatorPrecedence<Expr>()
opp.term = leaf.parse
lnprint(cStyle(parse(opp, "foo")!))
lnprint(cStyle(parse(opp, "foo + bar")!))



var expr = LateBound<Expr>()
let oparen = const("(") ~> skip
let cparen = const(")") ~> skip
let fnCall = oparen >~ pipe2(identifier, many(expr), Expr.MakeFn) ~> cparen
let choice = fnCall | leaf
expr.inner = choice.parse



let sexpr = "(f (add a (g b)) a (g c))"
let result6 = parse(expr, sexpr)
println("\(sexpr) = \(cStyle(result6!))")
