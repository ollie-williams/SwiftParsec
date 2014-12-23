import Cocoa
import Darwin

class Constant<T> : Parser {
  let value: T
  let str: String

  init(value:T) {
    self.value = value
    self.str = "\(value)"
  }

  typealias Target = T

  func parse(stream: CharStream) -> Target? {
    if stream.startsWith(str) {
      stream.advance(countElements(str))
      return value
    }
    stream.error("Expected \(str)")
    return nil
  }
}

func const<T>(value:T) -> Constant<T> {
  return Constant(value:value)
}

class Regex : Parser {
  typealias Target = String

  let pattern:String

  init(pattern:String) {
    self.pattern = pattern
  }

  func parse(stream:CharStream) -> Target? {
    if let match = stream.startsWithRegex(pattern) {
      stream.advance(countElements(match))
      return match
    }
    return nil
  }
}

func regex(pattern:String) -> Regex {
  return Regex(pattern:pattern)
}




// Helpful versions which turn arrays of Characters into Strings
func arrayToString<T:Parser where T.Target==Array<Character>>
  (parser: T) -> Pipe<T, String> {
  return pipe(parser, {return String($0)})
}

func manychars<T:Parser where T.Target==Character>
  (item:T) -> Pipe<Many<T>, String> {
  return arrayToString(many(item))
}

func many1chars<T:Parser where T.Target==Character>
  (item:T) -> Pipe<Many<T>, String> {
  return arrayToString(many1(item))
}

// Overloaded followed-by operators
func >~ <T: Parser>(first: String, second: T) -> FollowedBySecond<Constant<String>,T> {
  return FollowedBySecond(first: const(first), second: second)
}
func ~> <T: Parser>(first: T, second: String) -> FollowedByFirst<T,Constant<String>> {
  return FollowedByFirst(first: first, second: const(second))
}
