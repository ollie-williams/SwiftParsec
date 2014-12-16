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

let infixFormat = const("+") ~> skip
let opp = OperatorPrecedence<Expr>(infixFormat.parse)
opp.term = leaf.parse

class ExprOp {

  let symb:String

  init(symb:String) {
    self.symb = symb
  }

  func parse(opp:OperatorPrecedence<Expr>, stream:CharStream, left:Expr) -> Expr? {
    if let right = opp.parse(stream) {
      return Expr.MakeFn(symb, children:[left, right])
    }
    return nil
  }

  class func makeInfix(symb:String, _ ass:Associativity, _ prec:Int) -> Infix<Expr> {
    let inst = ExprOp(symb:symb)
    return Infix(ass:ass, prec:prec, impl:inst.parse)
  }
}

opp.addInfix("+", ExprOp.makeInfix("+", .Left, 60))

lnprint(cStyle(parse(opp, "foo")!))
lnprint(cStyle(parse(opp, "foo + bar")!))
lnprint(cStyle(parse(opp, "foo + bar + abc")!))



var expr = LateBound<Expr>()
let oparen = const("(") ~> skip
let cparen = const(")") ~> skip
let fnCall = oparen >~ pipe2(identifier, many(expr), Expr.MakeFn) ~> cparen
let choice = fnCall | leaf
expr.inner = choice.parse



let sexpr = "(f (add a (g b)) a (g c))"
let result6 = parse(expr, sexpr)
println("\(sexpr) = \(cStyle(result6!))")
