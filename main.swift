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

let skip = manychars(const(" "))
func idChar(c:Character) -> Bool {
  switch c {
    case "(", ")", " ", "!", "?", "+", "*":
      return false
    default:
      return true
  }
}
let identifier = many1chars(satisfy(idChar)) ~> skip
let leaf = identifier |> Expr.MakeLeaf

class ExprOp {
  let symb:String

  init(_ symb:String) {
    self.symb = symb
  }

  func binary(left:Expr, _ right:Expr) -> Expr {
    return Expr.MakeFn(symb, children:[left, right])
  }

  func unary(arg:Expr) -> Expr {
    return Expr.MakeFn(symb, children:[arg])
  }
}

let opFormat = (regex("[+*!?()]")) ~> skip
let opp = OperatorPrecedence<Expr>(opFormat.parse)

opp.addOperator("+", .LeftInfix(ExprOp("+").binary, 60))
opp.addOperator("*", .RightInfix(ExprOp("*").binary, 70))
opp.addPrefix("!", Prefix(ExprOp("!").unary, 200))
opp.addPrefix("?", Prefix(ExprOp("?").unary, 50))  

let oparen = const("(") ~> skip
let cparen = const(")") ~> skip


opp.term = leaf.parse// | oparen >~ opp ~> cparen

lnprint(cStyle(parse(opp, "foo")!))
lnprint(cStyle(parse(opp, "foo + bar")!))
lnprint(cStyle(parse(opp, "foo + bar + abc")!))
lnprint(cStyle(parse(opp, "foo * bar + abc")!))
lnprint(cStyle(parse(opp, "foo + bar * abc")!))
lnprint(cStyle(parse(opp, "foo * bar * abc")!))
lnprint(cStyle(parse(opp, "!foo")!))
lnprint(cStyle(parse(opp, "!?foo")!))
lnprint(cStyle(parse(opp, "!foo + bar")!))
lnprint(cStyle(parse(opp, "?foo + bar")!))




var expr = LateBound<Expr>()

let fnCall = oparen >~ pipe2(identifier, many(expr), Expr.MakeFn) ~> cparen
let choice = fnCall | leaf
expr.inner = choice.parse



let sexpr = "(f (add a (g b)) a (g c))"
let result6 = parse(expr, sexpr)
println("\(sexpr) = \(cStyle(result6!))")
