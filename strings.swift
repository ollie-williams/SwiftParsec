import Cocoa
import Darwin

class Constant : Parser {
  let str: String

  init(str:String) {
    self.str = str
  }

  typealias TargetType = String

  func parse<S: CharStream>(inout stream:S) -> TargetType? {
    if stream.startsWith(str) {
      stream = stream.advance(countElements(str))
      return str
    }
    stream.error("Expected \(str)")
    return nil
  }
}

func const(str: String) -> Constant {
  return Constant(str:str)
}

class ConstantChar : Parser {
  typealias TargetType = Character
  let ch : Character

  init(ch:Character) {
    self.ch = ch
  }

  func parse<S:CharStream>(inout stream:S) -> TargetType? {
    if let c = stream.head {
      if c == ch {
        stream = stream.advance(1)
        return c
      }
    }
    return nil
  }
}

func constchar(ch:Character) -> ConstantChar {
  return ConstantChar(ch:ch)
}


class Satisfy : Parser {
  let condition: Character -> Bool

  typealias TargetType = Character

  init(condition:Character -> Bool) {
    self.condition = condition
  }

  func parse<S: CharStream>(inout stream:S) -> TargetType? {
    if let ch = stream.head {
      if condition(ch) {
        stream = stream.advance(1)
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
