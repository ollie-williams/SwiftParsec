let source = BasicString(str: "HelloWorld")
let cnst1 = Constant(str: "Hello")
let cnst2 = Constant(str: "World")
let parser = cnst1 >>- cnst2
let result = parser.parse(source)
println(result.Value)

func function(s:String) -> Int { return countElements(s) }
let parser2 = Pipe(inner:parser, fn:function)
let result2 = parser2.parse(source)
println(result2.Value)
