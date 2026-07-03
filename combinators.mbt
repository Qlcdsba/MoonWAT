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

pub fn[A] Parser::optional(self : Parser[A]) -> Parser[Option[A]] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((val, next_state)) => Ok((Some(val), next_state))
      Err(_) => Ok((None, state))
    }
  })
}

pub fn[A] Parser::many0(self : Parser[A]) -> Parser[Array[A]] {
  Parser::new(fn(state) {
    let mut current_state = state
    let results = []
    let mut ok = true
    while ok {
      match self.parse(current_state) {
        Ok((val, next_state)) => {
          if next_state.offset == current_state.offset {
            ok = false
          } else {
            results.push(val)
            current_state = next_state
          }
        }
        Err(_) => ok = false
      }
    }
    Ok((results, current_state))
  })
}

pub fn[A] Parser::many1(self : Parser[A]) -> Parser[Array[A]] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((first_val, next_state)) => {
        let results = [first_val]
        let mut current_state = next_state
        let mut ok = true
        while ok {
          match self.parse(current_state) {
            Ok((val, ns)) => {
              if ns.offset == current_state.offset {
                ok = false
              } else {
                results.push(val)
                current_state = ns
              }
            }
            Err(_) => ok = false
          }
        }
        Ok((results, current_state))
      }
      Err(err) => Err(err)
    }
  })
}

pub fn[A, B] Parser::preceded(prefix : Parser[A], self : Parser[B]) -> Parser[B] {
  prefix.and_then(fn(_) { self })
}

pub fn[A, B] Parser::terminated(self : Parser[A], suffix : Parser[B]) -> Parser[A] {
  self.and_then(fn(val) {
    suffix.map(fn(_) { val })
  })
}

pub fn[A, B, C] Parser::delimited(left : Parser[A], self : Parser[B], right : Parser[C]) -> Parser[B] {
  left.and_then(fn(_) {
    self.and_then(fn(val) {
      right.map(fn(_) { val })
    })
  })
}

pub fn[A, B] Parser::separated_list(self : Parser[A], sep : Parser[B]) -> Parser[Array[A]] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((first_val, next_state)) => {
        let results = [first_val]
        let mut current_state = next_state
        let mut ok = true
        while ok {
          match sep.parse(current_state) {
            Ok((_, state_after_sep)) => {
              match self.parse(state_after_sep) {
                Ok((val, state_after_val)) => {
                  results.push(val)
                  current_state = state_after_val
                }
                Err(_) => ok = false
              }
            }
            Err(_) => ok = false
          }
        }
        Ok((results, current_state))
      }
      Err(_) => Ok(([], state))
    }
  })
}

pub fn[A, B] Parser::separated_list1(self : Parser[A], sep : Parser[B]) -> Parser[Array[A]] {
  Parser::new(fn(state) {
    match self.parse(state) {
      Ok((first_val, next_state)) => {
        let results = [first_val]
        let mut current_state = next_state
        let mut ok = true
        while ok {
          match sep.parse(current_state) {
            Ok((_, state_after_sep)) => {
              match self.parse(state_after_sep) {
                Ok((val, state_after_val)) => {
                  results.push(val)
                  current_state = state_after_val
                }
                Err(_) => ok = false
              }
            }
            Err(_) => ok = false
          }
        }
        Ok((results, current_state))
      }
      Err(err) => Err(err)
    }
  })
}
