extern crate regex;
use regex::Regex;

trait Parser<T> {
    fn parse(&self, s:&str) -> Option<(T,usize)>;
}

struct RxParser {
    rx:Regex
}

impl RxParser {
    fn new(pattern:&str) -> Self {
        let rx = match Regex::new(pattern) {
            Ok(re) => re,
            Err(err) => panic!("Error: {}", err),
        };
        return RxParser {rx: rx};
    }
}

impl Parser<String> for RxParser {

    fn parse(&self, s:&str) -> Option<(String,usize)> {
        let result = match self.rx.find(s) {
            Some(uv) => Some((String::from_str(&s[uv.0..uv.1]), uv.1)),
            None => None
        };
        return result;
    }

}

fn main() {
  let ipt = "Hello world!";

  let parser = RxParser::new(r"^Hello");
  if let Some(res) = parser.parse(ipt) {
      let rem = &ipt[res.1..];
      println!("Result: {}  Remainder: {}", res.0, rem);
  } else {
      println!("No match");
  }
}
