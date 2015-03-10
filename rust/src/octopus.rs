#![feature(plugin)]
#![plugin(regex_macros)]
extern crate regex;
use regex::Regex;
use std::str::FromStr;

trait Parser {
    type Output;
    fn parse(&self, s:&str) -> Option<(Self::Output,usize)>;
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
    type Output = String;

    fn parse(&self, s:&str) -> Option<(String,usize)> {
        if let Some(uv) = self.rx.find(s) {
            let value : String = s[uv.0..uv.1].to_string();
            return Some((value, uv.1));
        }
        return None;
    }
}


struct IntParser;
impl Parser for IntParser {
    type Output = i64;

    fn parse(&self, s:&str) -> Option<(i64,usize)> {
        let rx = regex!(r"^[+-]?[0-9]+");
        if let Some(uv) = rx.find(s) {
            let value = i64::from_str(&s[uv.0..uv.1]).unwrap();
            return Some((value, uv.1));
        }
        return None;
    }
}

struct FollowedBy<P1:Parser, P2:Parser> {
    first: P1,
    second: P2
}

impl<P1:Parser,P2:Parser> Parser for FollowedBy<P1,P2> {
    type Output = (P1::Output, P2::Output);

    fn parse(&self, s:&str) -> Option<((P1::Output,P2::Output),usize)> {
        if let Some(v1) = self.first.parse(s) {
            let s2 = &s[v1.1..];
            if let Some(v2) = self.second.parse(s2) {
                return Some(((v1.0,v2.0), v1.1 + v2.1));
            }
        }
        return None;
    }
}

/*
struct Pipe<P, F> {
    base: P,
    fun: F
}

impl<T1, P:Parser<T1>, T2, F:Fn(T1)->T2> Parser<T2> for Pipe<P,F> {
    fn parse(&self, s:&str) -> Option<(T2,usize)> {
        let result = match self.base.parse(s) {
            Some(res) => Some((self.fun(res.0), res.1)),
            None => None
        };
        return result;
    }
}
*/

fn main() {
  let ipt = "Hello42!";

  let p1 = RxParser::new(r"^Hello");
  let p2 = IntParser;
  let parser = FollowedBy {first:p1, second:p2};

  if let Some(res) = parser.parse(ipt) {
      let rem = &ipt[res.1..];
      let value = res.0;
      println!("Result: {}, {}\nRemainder: {}", value.0, value.1, rem);
  } else {
      println!("No match");
  }
}
