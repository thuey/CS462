ruleset Lab3App {
  meta {
    name "Lab3"
    description <<
      Lab3
    >>
    author ""
    logging off
  }
  global {
   
  }
  rule show_form {
    select when pageview url rel#.*#
    pre {
      text = <<
        <p>"hello this is testing paragraph insertion"</p>
        >>;
    }
    append("#main", text);
  }
}
