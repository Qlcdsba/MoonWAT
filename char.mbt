// Character and string level basic parsers

fn get_char(str : String, offset : Int) -> Char {
  str[offset].to_int().unsafe_to_char()
}

pub fn any_char() -> Parser[Char] {
  Parser::new(fn(state) {
    if state.offset < state.input.length() {
      let c = get_char(state.input, state.offset)
      let next_s = State::{
        input: state.input,
        offset: state.offset + 1,
        line: if c == '\n' { state.line + 1 } else { state.line },
        col: if c == '\n' { 1 } else { state.col + 1 }
      }
      Ok((c, next_s))
    } else {
      let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
      Err(ParseError::{ pos, detail: EOF })
    }
  })
}

pub fn satisfy(pred : (Char) -> Bool) -> Parser[Char] {
  Parser::new(fn(state) {
    if state.offset < state.input.length() {
      let c = get_char(state.input, state.offset)
      if pred(c) {
        let next_s = State::{
          input: state.input,
          offset: state.offset + 1,
          line: if c == '\n' { state.line + 1 } else { state.line },
          col: if c == '\n' { 1 } else { state.col + 1 }
        }
        Ok((c, next_s))
      } else {
        let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
        Err(ParseError::{ pos, detail: SatisfyFailed })
      }
    } else {
      let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
      Err(ParseError::{ pos, detail: EOF })
    }
  })
}

pub fn char(expected : Char) -> Parser[Char] {
  Parser::new(fn(state) {
    if state.offset < state.input.length() {
      let c = get_char(state.input, state.offset)
      if c == expected {
        let next_s = State::{
          input: state.input,
          offset: state.offset + 1,
          line: if c == '\n' { state.line + 1 } else { state.line },
          col: if c == '\n' { 1 } else { state.col + 1 }
        }
        Ok((c, next_s))
      } else {
        let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
        Err(ParseError::{ pos, detail: CharExpected(expected) })
      }
    } else {
      let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
      Err(ParseError::{ pos, detail: EOF })
    }
  })
}

pub fn tag(expected : String) -> Parser[String] {
  Parser::new(fn(state) {
    let expected_len = expected.length()
    if state.offset + expected_len <= state.input.length() {
      let mut i = 0
      let mut matches = true
      while i < expected_len {
        if state.input[state.offset + i] != expected[i] {
          matches = false
          break
        }
        i = i + 1
      }
      if matches {
        let mut next_line = state.line
        let mut next_col = state.col
        let mut k = 0
        while k < expected_len {
          let c = get_char(expected, k)
          if c == '\n' {
            next_line = next_line + 1
            next_col = 1
          } else {
            next_col = next_col + 1
          }
          k = k + 1
        }
        let next_s = State::{
          input: state.input,
          offset: state.offset + expected_len,
          line: next_line,
          col: next_col
        }
        Ok((expected, next_s))
      } else {
        let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
        Err(ParseError::{ pos, detail: TagExpected(expected) })
      }
    } else {
      let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
      Err(ParseError::{ pos, detail: EOF })
    }
  })
}
