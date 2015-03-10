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

impl<P1,P2> Parser for FollowedBy<P1,P2>
    where P1: Parser,
          P2: Parser
{
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

struct Pipe<P:Parser, F> {
    base: P,
    func: F,
}

impl<P, T, F> Parser for Pipe<P,F>
    where P: Parser,
          F: Fn(P::Output) -> T
{
    type Output = T;

    fn parse(&self, s:&str) -> Option<(T,usize)> {
        let result = match self.base.parse(s) {
            Some(res) => Some(((self.func)(res.0), res.1)),
            None => None
        };
        return result;
    }
}

struct Choice<P1:Parser, P2:Parser> {
    first: P1,
    second: P2
}

impl<P1,P2> Parser for Choice<P1,P2>
    where P1:Parser,
          P2:Parser<Output = P1::Output>
{
    type Output = P1::Output;

    fn parse(&self, s:&str) -> Option<(P1::Output,usize)> {
        if let Some(uv) = self.first.parse(s) {
            return Some(uv);
        }
        return self.second.parse(s);
    }
}


struct LateBound<P:Parser> {
    inner: Option<P>
}

/*
impl<P> Parser for LateBound<P>
    where P: Parser
{
    type Output = P::Output;

    fn parse(&self, s:&str) -> Op
}
*/

enum Expr {
    Leaf(String),
    Func(String, Box<Expr>)
}

impl Expr {
    fn make_leaf(name:String) -> Expr {
        Expr::Leaf(name)
    }

    fn make_func(name:String, arg:Expr) -> Expr {
        Expr::Func(name, Box::new(arg))
    }
}

fn drop<T>(x:T) -> T {
    x
}

fn main() {

  let identifier = RxParser {rx: regex!(r"^[_a-zA-Z][_a-zA-Z0-9]*")};
  let leaf = Pipe{ base:identifier, func: Expr::make_leaf };

  let oparen = RxParser { rx: regex!(r"^\(") };
  let cparen = RxParser { rx: regex!(r"^\)") };
  let skip = RxParser { rx: regex!(r"^\s*") };

  //let expr = [drop(oparen), identifier, drop(skip), leaf, drop(cparen)];


  let ipt = "Hello42!";
  if let Some(res) = leaf.parse(ipt) {
      if let Expr::Leaf(name) = res.0 {
          println!("leaf: {}", name);
      }
  }

  let p1 = RxParser::new(r"^Hello");
  let p2 = Pipe{ base:IntParser, func: |x| (2 * x) };
  let parser = FollowedBy {first:p1, second:p2};

  if let Some(res) = parser.parse(ipt) {
      let rem = &ipt[res.1..];
      let value = res.0;
      println!("Result: {}, {}\nRemainder: {}", value.0, value.1, rem);
  } else {
      println!("No match");
  }
}
