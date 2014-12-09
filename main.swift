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

let skip = manychars(constchar(" "))

func idChar(c:Character) -> Bool {
  switch c {
    case "(", ")", " ":
      return false
    default:
      return true
  }
}
let identifier = many1chars(satisfy(idChar)) ->> skip

let result4 = "fooble_barble gr" |> identifier >> identifier
println(result4)


enum MyEnum {
  case Number(Int)
  case Word(String)

  func tell() -> Void {
    switch self {
      case .Number(let v): println(v)
      case .Word(let s): println(s)
    }
  }
}

let trigger = pipe(const("Hello") ->> skip, { (s:String) -> MyEnum in return MyEnum.Number(42)})
let opt = trigger | pipe(identifier, {return MyEnum.Word($0)})
let result5 = "Hello fooble Hello" |> many(opt)
//println(result5)
map(result5!, {$0.tell()})

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
