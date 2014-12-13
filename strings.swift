import Cocoa
import Darwin

class Constant<T> : Parser {
  let value: T
  let str: String

  init(value:T) {
    self.value = value
    self.str = "\(value)"
  }

  typealias TargetType = T

  func parse(stream: CharStream) -> TargetType? {
    if stream.startsWith(str) {
      stream.advance(countElements(str))
      return value
    }
    stream.error("Expected \(str)")
    return nil
  }
}

func const(str: String) -> Constant<String> {
  return Constant(value:str)
}

func constchar(ch:Character) -> Constant<Character> {
  return Constant(value:ch)
}


class Satisfy : Parser {
  let condition: Character -> Bool

  typealias TargetType = Character

  init(condition:Character -> Bool) {
    self.condition = condition
  }

  func parse(stream:CharStream) -> TargetType? {
    if let ch = stream.head {
      if condition(ch) {
        stream.advance(1)
        return ch
      }
    }
    return nil
  }
}

func satisfy(condition:Character->Bool) -> Satisfy {
  return Satisfy(condition)
}


// Helpful versions which turn arrays of Characters into Strings
func arrayToString<T:Parser where T.TargetType==Array<Character>>
  (parser: T) -> Pipe<T, String> {
  return pipe(parser, {return String($0)})
}

func manychars<T:Parser where T.TargetType==Character>
  (item:T) -> Pipe<Many<T>, String> {
  return arrayToString(many(item))
}

func many1chars<T:Parser where T.TargetType==Character>
  (item:T) -> Pipe<Many<T>, String> {
  return arrayToString(many1(item))
}

// Overloaded followed-by operators
func >>- <T: Parser>(first: String, second: T) -> FollowedBySecond<Constant<String>,T> {
  return FollowedBySecond(first: const(first), second: second)
}
func ->> <T: Parser>(first: T, second: String) -> FollowedByFirst<T,Constant<String>> {
  return FollowedByFirst(first: first, second: const(second))
}
