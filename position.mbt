// Position tracking and diagnostics

fn get_char_helper(str : String, offset : Int) -> Char {
  str[offset].to_int().unsafe_to_char()
}

pub fn[A] Parser::span(self : Parser[A]) -> Parser[(A, Span)] {
  Parser::new(fn(state) {
    let start_pos = Position::{ line: state.line, col: state.col, offset: state.offset }
    match self.parse(state) {
      Ok((val, next_state)) => {
        let end_pos = Position::{ line: next_state.line, col: next_state.col, offset: next_state.offset }
        let s = Span::{ start: start_pos, end: end_pos }
        Ok(((val, s), next_state))
      }
      Err(err) => Err(err)
    }
  })
}

pub fn ParseError::format(self : ParseError, input : String) -> String {
  let mut line_start = 0
  let err_offset = self.pos.offset
  
  // Find start of the line containing the error
  let mut i = err_offset
  while i > 0 {
    let prev_char = get_char_helper(input, i - 1)
    if prev_char == '\n' {
      line_start = i
      break
    }
    i = i - 1
  }
  
  // Find end of the line
  let mut line_end = input.length()
  let mut j = err_offset
  while j < input.length() {
    let c = get_char_helper(input, j)
    if c == '\n' {
      line_end = j
      break
    }
    j = j + 1
  }
  
  // Extract line content
  let mut line_str = ""
  let mut k = line_start
  while k < line_end {
    line_str = line_str + get_char_helper(input, k).to_string()
    k = k + 1
  }
  
  // Build visual pointer alignment
  let mut pointer_str = ""
  let col = self.pos.col
  let mut col_idx = 1
  while col_idx < col {
    pointer_str = pointer_str + " "
    col_idx = col_idx + 1
  }
  pointer_str = pointer_str + "^"
  
  let detail_str = self.detail.to_string()
  "Parse error at line \{self.pos.line}, col \{self.pos.col}:\n" +
  "  \{line_str}\n" +
  "  \{pointer_str} -- \{detail_str}"
}
