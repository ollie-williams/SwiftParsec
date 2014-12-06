import Darwin
import Cocoa

//---------------------------------//
// Inputs
//---------------------------------//
protocol CharStream {
  func startsWith(String) -> Bool
  func advance(Int) -> Self
}

final class BasicString : CharStream {
  let str: String

  init(str: String) {
    self.str = str
  }

  func startsWith(query: String) -> Bool {
    return str.hasPrefix(query)
  }

  func advance(count: Int) -> BasicString {
    let index = Swift.advance(str.startIndex, count)
    let substring = str.substringFromIndex(index)
    return BasicString(str: substring)
  }
}




//---------------------------------//
// Outputs
//---------------------------------//

// box class is used to wrap some other object into a reference so that
// generic enums are fixed size (something the fledgeling code generator
// currently requires)
class Box<T> {
  let item: T
  init(item: T) {
    self.item = item
  }
}

enum Result<T, S : CharStream> {
  case Success(Box<T>, Box<S>)
  case Failure(Box<S>, String)

  init(value: T, stream: S) {
    self = .Success(Box<T>(item: value), Box<S>(item: stream))
  }
  init(stream: S, msg: String) {
    self = .Failure(Box<S>(item: stream), msg)
  }

  var Value: T? {
    get {
      switch self {
        case Success(let val, _):
          return val.item
        default:
          return nil
      }
    }
  }
}

//---------------------------------//
// Parsing
//---------------------------------//
protocol Parser {
  typealias TargetType
  func parse<S:CharStream>(S) -> Result<TargetType, S>
}

class Constant : Parser {
  let str: String

  init(str:String) {
    self.str = str
  }

  typealias TargetType = String

  func parse<S: CharStream>(stream: S) -> Result<TargetType, S> {
    if stream.startsWith(str) {
      return Result<TargetType, S>(
        value : str,
        stream: stream.advance(countElements(str)))
    } else {
      return Result<TargetType, S>(
        stream: stream,
        msg   : "Expected \(str)")
    }
  }
}
/*
class FollowedBy<T1 : Parser, T2 : Parser> : Parser {
  let first : T1
  let second: T2

  init(first:T1, second:T2) {
    self.first = first
    self.second = second
  }

  typealias R1 = T1.ReturnType
  typealias R2 = T2.ReturnType
  typealias ReturnType = (R1,R2)

  func Parse(str:CharStream) -> ReturnType? {
    if let fst = first.Parse(str) {
      if let snd = second.Parse(str) {
        return (fst,snd)
      }
    }
    return nil
  }
}
*/

let source = BasicString(str: "Hello world")
let cnst = Constant(str: "Hello")
let result = cnst.parse(source)
println(result.Value)
