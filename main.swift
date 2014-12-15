func lnprint<T>(val:T, file: String = __FILE__, line: Int = __LINE__) -> Void {
  println("\(file)(\(line)): \(val)")
}

let source = "HelloWorld"
let cnst1 = const("Hello")
let cnst2 = const("World")
let parser = cnst1 >~ cnst2
let result = source |> parser
lnprint(result)

func function(s:String) -> Int { return countElements(s) }
let parser2 = pipe(parser, function)
let result2 = source |> parser2
lnprint(result2)

let result3 = "HelloHelloHelloWorld" |> many(const("Hello")) >~ const("World")
lnprint(result3)

class Expr {
  let symbol  : String
  let children: [Expr]

  init(symbol:String, children:[Expr]) {
    self.symbol = symbol
    self.children = children
  }

  func tell() -> String {
    if children.count == 0 {
      return symbol
    }
    let tail = children.reduce("", combine: {$0 + " " + $1.tell()})
    return "(\(symbol)\(tail))"
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

let result4 = "fooble_barble gr" |> identifier ~>~ identifier
lnprint(result4)

var expr = LateBound<Expr>()
let fnCall = "(" >~ pipe2(identifier, many(expr), Expr.MakeFn) ~> ")" ~> skip
let solo = pipe(identifier, Expr.MakeLeaf)
let choice = fnCall | solo
expr.inner = choice.parse

let result6 = "(f a (b c) (g a b c))" |> expr
lnprint(result6!.tell())
