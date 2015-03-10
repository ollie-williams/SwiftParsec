extern crate regex;
use regex::Regex;

fn find_hello(s:&str) -> Option<usize> {
    let rx = match Regex::new(r"^Hello") {
        Ok(re) => re,
        Err(err) => panic!("Error: {}", err),
    };

    match rx.find(s) {
        Some(uv) => return Some(uv.1),
        None => return None
    }
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
