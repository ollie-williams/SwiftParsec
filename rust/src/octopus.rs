#![feature(plugin)]
#![plugin(regex_macros)]
extern crate regex;
use regex::Regex;
use std::str::FromStr;

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
        if let Some(uv) = self.rx.find(s) {
            let value : String = s[uv.0..uv.1].to_string();
            return Some((value, uv.1));
        }
        return None;
    }
}


struct IntParser;
impl Parser<i64> for IntParser {
    fn parse(&self, s:&str) -> Option<(i64,usize)> {
        let rx = regex!(r"^[+-]?[0-9]+");
        if let Some(uv) = rx.find(s) {
            let value = i64::from_str(&s[uv.0..uv.1]).unwrap();
            return Some((value, uv.1));
        }
        return None;
    }
}

struct FollowedBy<P1,P2> {
    first: P1,
    second: P2
}

impl<T1,T2,P1:Parser<T1>,P2:Parser<T2>> Parser<(T1,T2)> for FollowedBy<P1,P2> {
    fn parse(&self, s:&str) -> Option<((T1,T2),usize)> {
        if let Some(v1) = self.first.parse(s) {
            let s2 = &s[v1.1..];
            if let Some(v2) = self.second.parse(s2) {
                return Some(((v1.0,v2.0), v1.1 + v2.1));
            }
        }
        return None;
    }
}


struct Pipe<T1, P:Parser<T1>, T2> {
    base: P,
    fun: Fn(T1) -> T2
}

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
