extern crate regex;
use regex::Regex;

fn main() {
  let ipt = "Hello world!";
  let rx = match Regex::new(r"^Hello") {
      Ok(re) => re,
      Err(err) => panic!("Error: {}", err)
  };

  let fnd = rx.find(ipt);
  if let Some(uv) = fnd {
      println!("{} {}", uv.0, uv.1);
      let rem = &ipt[uv.1..];
      println!("Remainder: {}", rem);
  } else {
      println!("No match");
      return;
  }

}
