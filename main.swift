import Darwin

func lnprint<T>(val:T, file: String = __FILE__, line: Int = __LINE__) -> Void {
  println("\(file)(\(line)): \(val)")
}

// Skip over whitespace
let skip = manychars(const(" "))

// Useful character constants
let oparen = const("(") ~> skip
let cparen = const(")") ~> skip
let comma = const(",") ~> skip

// The operator precendence parser at the heart of our calculator
let opFormat = (regex("[+*-/\\^]")) ~> skip
let opp = OperatorPrecedence<Double>(opFormat.parse)

// Floating-point number literals
let flt = FloatParser(strict:false) ~> skip

// Infix operators
opp.addOperator("+", .LeftInfix({return $0 + $1}, 60))
opp.addOperator("-", .LeftInfix({return $0 - $1}, 60))
opp.addOperator("*", .LeftInfix({return $0 * $1}, 70))
opp.addOperator("/", .LeftInfix({return $0 / $1}, 70))
opp.addOperator("^", .LeftInfix({return pow($0,$1)}, 80))


// Functions
let arg1 = oparen >~ opp ~> cparen
let sinfunc = const("sin") >~ arg1 |> sin
let cosfunc = const("cos") >~ arg1 |> cos
let tanfunc = const("tan") >~ arg1 |> tan
let expfunc = const("exp") >~ arg1 |> exp
let logfunc = const("log") >~ arg1 |> log
let sqrtfunc = const("sqrt") >~ arg1 |> sqrt
let funcs = sinfunc | cosfunc | tanfunc | expfunc | logfunc | sqrtfunc

// A term in brackets
let brackets = oparen >~ opp ~> cparen

// Parsing terms within an infix expression
let termParser  = funcs | brackets | flt
opp.term = termParser.parse

func parse<T:Parser>(parser:T, string:String) -> T.Target? {
  var stream = CharStream(str:string)
  return parser.parse(stream)
}

import Cocoa

func readline() -> String {
  var keyboard = NSFileHandle.fileHandleWithStandardInput()
  var inputData = keyboard.availableData
  return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func mainloop() -> Void {
  while(true) {
    print("> ")
    fflush(__stdoutp)
    let s = readline()
    let stream = CharStream(str:s)
    if stream.startsWith("quit") || stream.startsWith("exit") {
      return
    }

    if let result = opp.parse(stream) {
      println(result)
    } else {
      println("syntax error")
    }
  }
}

mainloop()

// Identifiers
//let identifier = regex("[_a-zA-Z][_a-zA-Z0-9]*") ~> skip





/*

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
    case "(", ")", " ", "!", "?", "+", "*", ",":
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

let opFormat = (regex("[+*!?-]")) ~> skip
let opp = OperatorPrecedence<Expr>(opFormat.parse)

opp.addOperator("+", .LeftInfix(ExprOp("+").binary, 60))
opp.addOperator("-", .LeftInfix(ExprOp("-").binary, 60))
opp.addOperator("*", .RightInfix(ExprOp("*").binary, 70))
opp.addPrefix("!", Prefix(ExprOp("!").unary, 200))
opp.addPrefix("?", Prefix(ExprOp("?").unary, 50))
opp.addPrefix("-", Prefix(ExprOp("-").unary, 200))
opp.addPrefix("+", Prefix(ExprOp("+").unary, 200))

let oparen = const("(") ~> skip
let cparen = const(")") ~> skip
let comma = const(",") ~> skip

let brackets = oparen >~ opp ~> cparen
let fncall = identifier ~>~ (oparen >~ sepby(opp, comma) ~> cparen) |> Expr.MakeFn

let flt = FloatParser(strict:false) ~> skip
lnprint(parse(flt, "-123"))
lnprint(parse(flt, "12.3"))
lnprint(parse(flt, "0.123"))
lnprint(parse(flt, "-.123"))
lnprint(parse(flt, "-12.3e39"))

let number = flt |> {(x:Double)->Expr in Expr.MakeLeaf("\(x)")}

let termParser  = fncall | brackets | number | leaf
opp.term = termParser.parse

lnprint(cStyle(parse(opp, "foo")!))
lnprint(cStyle(parse(opp, "foo + bar")!))
lnprint(cStyle(parse(opp, "foo + bar + abc")!))
lnprint(cStyle(parse(opp, "foo * bar + abc")!))
lnprint(cStyle(parse(opp, "22.3 + foo * abc")!))
lnprint(cStyle(parse(opp, "foo * abc + 43.79e3")!))
lnprint(cStyle(parse(opp, "foo + !43.79e3 * abc")!))
lnprint(cStyle(parse(opp, "22.3 + foo * abc")!))
lnprint(cStyle(parse(opp, "foo * (bar + abc)")!))
lnprint(cStyle(parse(opp, "foo * bar * abc")!))
lnprint(cStyle(parse(opp, "!foo")!))
lnprint(cStyle(parse(opp, "!?foo")!))
lnprint(cStyle(parse(opp, "!foo + bar")!))
lnprint(cStyle(parse(opp, "!(foo + bar)")!))
lnprint(cStyle(parse(opp, "?foo + bar")!))
lnprint(cStyle(parse(opp, "sqrt(a + b)")!))
lnprint(cStyle(parse(opp, "goo(a + b, c * sqrt(d))")!))
lnprint(cStyle(parse(opp, "foo - -bar")!))
lnprint(cStyle(parse(opp, "foo - -22.9")!))

*/
