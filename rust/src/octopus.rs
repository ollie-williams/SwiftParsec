extern crate regex;
use regex::Regex;

trait Parser {
    fn parse(&self, s:&str) -> Option<usize>;
}

struct RxParser {
    rx:Regex
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

fn find(rx:Regex, s:&str) -> Option<usize> {
    let rxp = RxParser { rx: rx };
    return rxp.parse(s);
}

fn find_hello(s:&str) -> Option<usize> {
    let rx = match Regex::new(r"^Hello") {
        Ok(re) => re,
        Err(err) => panic!("Error: {}", err),
    };
    return find(rx, s);
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
