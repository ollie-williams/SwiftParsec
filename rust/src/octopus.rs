#![feature(plugin)]
#![plugin(regex_macros)]
extern crate regex;
use regex::Regex;
extern crate core;
use core::ops::Shr;
use core::ops::Shl;
use std::str::FromStr;
use std::clone::Clone;

trait Parser {
    type Output;
    fn parse(&self, s:&str) -> Option<(Self::Output,usize)>;

    fn parse_ignore(&self, s:&str) -> Option<usize> {
        match self.parse(s) {
            Some(uv) => Some(uv.1),
            None     => None
        }
    }
}

// References to parsers are also parsers
impl<'a, P> Parser for &'a P
    where P:Parser
{
    type Output = P::Output;

    fn parse(&self, s:&str) -> Option<(P::Output,usize)> {
        (*self).parse(s)
    }
}


// RxParser
//
// Parse a regular expression
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

// IntParser
//
// Parse an integer
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

// FollowedBy
//
// Combinator for connectiong one parser to another in series
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

struct FollowedByFirst<P1:Parser, P2:Parser> {
    first: P1,
    second: P2
}
impl<P1,P2> Parser for FollowedByFirst<P1,P2>
    where P1: Parser,
          P2: Parser
{
    type Output = P1::Output;

    fn parse(&self, s:&str) -> Option<(P1::Output, usize)> {
        if let Some(v1) = self.first.parse(s) {
            let s2 = &s[v1.1..];
            if let Some(v2) = self.second.parse_ignore(s2) {
                return Some((v1.0, v1.1 + v2));
            }
        }
        return None;
    }
}

struct FollowedBySecond<P1:Parser, P2:Parser> {
    first: P1,
    second: P2
}
impl<P1,P2> Parser for FollowedBySecond<P1,P2>
    where P1: Parser,
          P2: Parser
{
    type Output = P2::Output;

    fn parse(&self, s:&str) -> Option<(P2::Output, usize)> {
        if let Some(v1) = self.first.parse_ignore(s) {
            let s2 = &s[v1..];
            if let Some(v2) = self.second.parse(s2) {
                return Some((v2.0, v1 + v2.1));
            }
        }
        return None;
    }
}



// Pipe
//
// Maps the output of a parser with a given function
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

// Prsr
//
// Boxing struct used to encapsulate implementations of Parser so that it is possible to provide
// operator overloading
struct Prsr<P:Parser> {
    p: P
}
impl<P> Prsr<P> where P:Parser {
    fn new(p:P) -> Prsr<P> {
        Prsr {p:p}
    }
}
impl<P> Parser for Prsr<P>
    where P:Parser
{
    type Output = P::Output;
    fn parse(&self, s:&str) -> Option<(P::Output,usize)> {
        self.p.parse(s)
    }
}

// Shr >>
//
// Implements the >> operator for two Prsrs by interpreting it as FollowedBySecond, that is: p1 >>
// p2 parses p1 and then p2 in series, but only keeps the result of p2.
impl<'a, P1, P2> Shr<&'a Prsr<P2>> for &'a Prsr<P1>
    where P1:Parser,
          P2:Parser
{
    type Output = Prsr<FollowedBySecond<&'a P1,&'a P2>>;

    fn shr(self, rhs:&'a Prsr<P2>) -> Prsr<FollowedBySecond<&'a P1,&'a P2>> {
        Prsr::new( FollowedBySecond{first:&self.p, second:&rhs.p} )
    }
}

// Shl <<
//
// Implements the << operator for two Prsrs by interpreting it as FollowedByFirst, that is: p1 <<
// p2 parses p1 and p2 in series, but only keeps the result of p1.
impl<'a, P1, P2> Shl<&'a Prsr<P2>> for &'a Prsr<P1>
    where P1:Parser,
          P2:Parser
{
    type Output = Prsr<FollowedByFirst<&'a P1,&'a P2>>;

    fn shl(self, rhs:&'a Prsr<P2>) -> Prsr<FollowedByFirst<&'a P1,&'a P2>> {
        Prsr::new( FollowedByFirst{first:&self.p, second:&rhs.p} )
    }
}

impl<'a, P1, P2> Shl<&'a Prsr<P2>> for Prsr<P1>
    where P1:Parser,
          P2:Parser
{
    type Output = Prsr<FollowedByFirst<P1,&'a P2>>;

    fn shl(self, rhs:&'a Prsr<P2>) -> Prsr<FollowedByFirst<P1,&'a P2>> {
        Prsr::new( FollowedByFirst{first:self.p, second:&rhs.p} )
    }
}

fn main() {

  let identifier = RxParser {rx: regex!(r"^[_a-zA-Z][_a-zA-Z0-9]*")};
  let leaf = Pipe{ base:identifier, func: Expr::make_leaf };
  let leafr = Prsr::new( leaf );

  let oparen = RxParser { rx: regex!(r"^\(") };
  let cparen = RxParser { rx: regex!(r"^\)") };
  let skip = RxParser { rx: regex!(r"^\s*") };
  let skipr = Prsr::new( skip );

  let skipleaf = &skipr >> &leafr << &skipr;
  //oparen >> (identifier + (skip >> leaf)) << cparen
  //[box drop(oparen), box identifier, box drop(skip), box leaf, box drop(cparen)];


  let ipt = "Hello42!";
  if let Some(res) = skipleaf.parse(ipt) {
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
