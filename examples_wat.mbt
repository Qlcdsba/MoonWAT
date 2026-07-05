// WebAssembly Text Format (WAT) S-Expression AST and Parser

pub enum SExpr {
  Atom(String)
  SList(Array[SExpr])
} derive(Eq)

pub impl Show for SExpr with fn output(self, logger) {
  match self {
    Atom(s) => logger.write_string(s)
    SList(arr) => {
      logger.write_string("(")
      let mut i = 0
      while i < arr.length() {
        if i > 0 { logger.write_string(" ") }
        arr[i].output(logger)
        i = i + 1
      }
      logger.write_string(")")
    }
  }
}

fn chars_to_str_helper(arr : Array[Char]) -> String {
  let mut s = ""
  let mut i = 0
  while i < arr.length() {
    s = s + arr[i].to_string()
    i = i + 1
  }
  s
}

// Parses WAT line comment starting with ;;
pub fn wat_line_comment() -> Parser[Unit] {
  tag(";;").and_then(fn(_) {
    satisfy(fn(c) { c != '\n' }).many0().and_then(fn(_) {
      char('\n').optional().map(fn(_) { () })
    })
  })
}

// Parses WAT block comment enclosed in (; ;)
pub fn wat_block_comment() -> Parser[Unit] {
  tag("(;").and_then(fn(_) {
    Parser::new(fn(state) {
      let mut offset = state.offset
      let mut line = state.line
      let mut col = state.col
      let mut ok = false
      while offset + 1 < state.input.length() {
        let c1 = get_char(state.input, offset)
        let c2 = get_char(state.input, offset + 1)
        if c1 == ';' && c2 == ')' {
          offset = offset + 2
          col = col + 2
          ok = true
          break
        }
        if c1 == '\n' {
          line = line + 1
          col = 1
          offset = offset + 1
        } else {
          col = col + 1
          offset = offset + 1
        }
      }
      if ok {
        let next_s = State::{ input: state.input, offset, line, col }
        Ok(((), next_s))
      } else {
        let pos = Position::{ line: state.line, col: state.col, offset: state.offset }
        Err(ParseError::{ pos, detail: EOF })
      }
    })
  })
}

// Combines standard whitespaces and comments
pub fn wat_ignored() -> Parser[Unit] {
  let ws = satisfy(fn(c) { c == ' ' || c == '\t' || c == '\r' || c == '\n' }).map(fn(_) { () })
  ws.or(wat_line_comment()).or(wat_block_comment())
}

pub fn wat_spaces() -> Parser[Array[Unit]] {
  wat_ignored().many0()
}

pub fn wat_spaced[A](p : Parser[A]) -> Parser[A] {
  wat_spaces().preceded(p).terminated(wat_spaces())
}

pub fn wat_atom_char() -> Parser[Char] {
  satisfy(fn(c) {
    c != ' ' && c != '\t' && c != '\r' && c != '\n' &&
    c != '(' && c != ')' && c != ';' && c != '"'
  })
}

pub fn wat_atom() -> Parser[SExpr] {
  // Either double quoted string literal or normal character sequence
  let parse_str = json_string_literal().map(fn(s) { Atom("\"" + s + "\"") })
  let parse_word = wat_atom_char().many1().map(fn(arr) { Atom(chars_to_str_helper(arr)) })
  wat_spaced(parse_str.or(parse_word))
}

pub fn wat_list() -> Parser[SExpr] {
  Parser::new(fn(state) {
    let p = wat_spaced(char('('))
      .preceded(wat_expr().many0())
      .terminated(wat_spaced(char(')')))
      .map(fn(arr) { SList(arr) })
    p.parse(state)
  })
}

pub fn wat_expr() -> Parser[SExpr] {
  Parser::new(fn(state) {
    let p = wat_list().or(wat_atom())
    p.parse(state)
  })
}
