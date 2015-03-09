extern crate regex;
use regex::Regex;

fn main() {
  let ipt = "Hello world!";
  let rx = match Regex::new(r"^Hello") {
      Ok(re) => re,
      Err(err) => panic!("Error: {}", err)
  };

  if rx.is_match(ipt) {
      println!("Match\n");
  } else {
      println!("No match\n");
  }
}
