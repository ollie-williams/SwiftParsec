class Token<T:Parser, V> : Parser {
  typealias Target = V

  let trigger: T
  let value:   V

  init(trigger:T, value:V) {
    self.trigger = trigger
    self.value = value
  }

  func parse(stream:CharStream) -> Target? {
    if let _ = trigger.parse(stream) {
      return value
    }
    return nil
  }
}

func token<T:Parser, V>(trigger:T, value:V) -> Token<T,V> {
  return Token(trigger:trigger, value:value)
}
