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

  var Stream: S {
    get {
      switch self {
        case .Success(_, let stream):
          return stream.item
        case .Failure(let stream, _):
          return stream.item
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
      return Result(
        value : str,
        stream: stream.advance(countElements(str)))
    } else {
      return Result(
        stream: stream,
        msg   : "Expected \(str)")
    }
  }
}
