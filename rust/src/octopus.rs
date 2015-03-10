extern crate regex;
use regex::Regex;

trait Parser {
    fn parse(&self, s:&str) -> Option<usize>;
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

impl Parser for RxParser {
    fn parse(&self, s:&str) -> Option<usize> {
        let result = match self.rx.find(s) {
            Some(uv) => Some(uv.1),
            None => None
        };
        return result;
    }
}

fn find_hello(s:&str) -> Option<usize> {
    let parser = RxParser::new(r"^Hello");
    return parser.parse(s);
}

fn main() {
  let ipt = "Hello world!";

  if let Some(ind) = find_hello(ipt) {
      let rem = &ipt[ind..];
      println!("Remainder: {}", rem);
  } else {
      println!("No match");
  }
}
