// Fundamental parser combinators

pub fn[A, B] Parser::map(self : Parser[A], f : (A) -> B) -> Parser[B] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((val, next_state)) => Ok((f(val), next_state))
      Err(err) => Err(err)
    }
  })
}

pub fn[A, B] Parser::and_then(self : Parser[A], f : (A) -> Parser[B]) -> Parser[B] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((val, next_state)) => f(val).parse(next_state)
      Err(err) => Err(err)
    }
  })
}

pub fn[A] Parser::or(self : Parser[A], other : Parser[A]) -> Parser[A] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok(res) => Ok(res)
      Err(_) => other.parse(state)
    }
  })
}
