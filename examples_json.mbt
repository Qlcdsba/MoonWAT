// Fully compliant JSON AST and parser example

pub enum JsonValue {
  JsonNull
  JsonBool(Bool)
  JsonNumber(Double)
  JsonString(String)
  JsonArray(Array[JsonValue])
  JsonObject(Array[(String, JsonValue)])
} derive(Eq)

pub impl Show for JsonValue with fn output(self, logger) {
  match self {
    JsonNull => logger.write_string("null")
    JsonBool(b) => logger.write_string(b.to_string())
    JsonNumber(n) => logger.write_string(n.to_string())
    JsonString(s) => logger.write_string("\"" + s + "\"")
    JsonArray(arr) => {
      logger.write_string("[")
      let mut i = 0
      while i < arr.length() {
        if i > 0 { logger.write_string(", ") }
        arr[i].output(logger)
        i = i + 1
      }
      logger.write_string("]")
    }
    JsonObject(obj) => {
      logger.write_string("{")
      let mut i = 0
      while i < obj.length() {
        if i > 0 { logger.write_string(", ") }
        let (k, v) = obj[i]
        logger.write_string("\"" + k + "\": ")
        v.output(logger)
        i = i + 1
      }
      logger.write_string("}")
    }
  }
}

fn chars_to_str(arr : Array[Char]) -> String {
  let mut s = ""
  let mut i = 0
  while i < arr.length() {
    s = s + arr[i].to_string()
    i = i + 1
  }
  s
}

pub fn json_whitespace() -> Parser[Char] {
  satisfy(fn(c) { c == ' ' || c == '\t' || c == '\r' || c == '\n' })
}

pub fn json_spaces() -> Parser[Array[Char]] {
  json_whitespace().many0()
}

pub fn spaced[A](p : Parser[A]) -> Parser[A] {
  json_spaces().preceded(p).terminated(json_spaces())
}

pub fn json_null() -> Parser[JsonValue] {
  spaced(tag("null")).map(fn(_) { JsonNull })
}

pub fn json_bool() -> Parser[JsonValue] {
  spaced(bool()).map(fn(b) { JsonBool(b) })
}

pub fn json_number() -> Parser[JsonValue] {
  spaced(float()).map(fn(n) { JsonNumber(n) })
}

pub fn json_escape() -> Parser[Char] {
  tag("\\\"").map(fn(_) { '"' })
    .or(tag("\\\\").map(fn(_) { '\\' }))
    .or(tag("\\/").map(fn(_) { '/' }))
    .or(tag("\\n").map(fn(_) { '\n' }))
    .or(tag("\\r").map(fn(_) { '\r' }))
    .or(tag("\\t").map(fn(_) { '\t' }))
}

pub fn json_char() -> Parser[Char] {
  json_escape().or(satisfy(fn(c) { c != '"' && c != '\\' }))
}

pub fn json_string_literal() -> Parser[String] {
  char('"')
    .preceded(json_char().many0())
    .terminated(char('"'))
    .map(chars_to_str)
}

pub fn json_string() -> Parser[JsonValue] {
  spaced(json_string_literal()).map(fn(s) { JsonString(s) })
}

pub fn json_array() -> Parser[JsonValue] {
  Parser::new(fn(state) {
    let p = spaced(char('['))
      .preceded(json_value().separated_list(spaced(char(','))))
      .terminated(spaced(char(']')))
      .map(fn(arr) { JsonArray(arr) })
    p.parse(state)
  })
}

pub fn json_object() -> Parser[JsonValue] {
  Parser::new(fn(state) {
    let pair = json_string_literal()
      .terminated(spaced(char(':')))
      .and_then(fn(k) {
        json_value().map(fn(v) { (k, v) })
      })
    let p = spaced(char('{'))
      .preceded(pair.separated_list(spaced(char(','))))
      .terminated(spaced(char('}')))
      .map(fn(obj) { JsonObject(obj) })
    p.parse(state)
  })
}

pub fn json_value() -> Parser[JsonValue] {
  Parser::new(fn(state) {
    let p = json_null()
      .or(json_bool())
      .or(json_number())
      .or(json_string())
      .or(json_array())
      .or(json_object())
    p.parse(state)
  })
}
