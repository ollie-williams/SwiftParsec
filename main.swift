let source = BasicString(str: "HelloWorld")
let cnst1 = Constant(str: "Hello")
let cnst2 = Constant(str: "World")
let parser = cnst1 >> cnst2
let result = parser.parse(source)
println(result.Value)
