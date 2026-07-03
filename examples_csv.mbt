// RFC 4180 Compliant CSV Parser Example

fn chars_to_string(arr : Array[Char]) -> String {
  let mut s = ""
  let mut i = 0
  while i < arr.length() {
    s = s + arr[i].to_string()
    i = i + 1
  }
  s
}

// Parses escaped double quotes "" inside a quoted field and returns a single "
pub fn escaped_quote() -> Parser[Char] {
  tag("\"\"").map(fn(_) { '"' })
}

// Parses any character that is not a double quote, or an escaped double quote
pub fn quoted_char() -> Parser[Char] {
  escaped_quote().or(satisfy(fn(c) { c != '"' }))
}

// Parses a quoted field delimited by double quotes
pub fn csv_quoted_field() -> Parser[String] {
  char('"')
    .preceded(quoted_char().many0())
    .terminated(char('"'))
    .map(chars_to_string)
}

// Parses an unquoted field (any character except commas, double quotes, CR, and LF)
pub fn csv_unquoted_field() -> Parser[String] {
  satisfy(fn(c) { c != ',' && c != '"' && c != '\r' && c != '\n' })
    .many0()
    .map(chars_to_string)
}

// Parses a single CSV field (either quoted or unquoted)
pub fn csv_field() -> Parser[String] {
  csv_quoted_field().or(csv_unquoted_field())
}

// Parses a single CSV record (a row of fields separated by commas)
pub fn csv_record() -> Parser[Array[String]] {
  csv_field().separated_list(char(','))
}

// Parses a complete CSV document containing rows separated by CRLF or LF
pub fn csv_document() -> Parser[Array[Array[String]]] {
  let newline = tag("\r\n").or(tag("\n"))
  csv_record().separated_list(newline)
}
