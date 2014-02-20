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
    select when pageview ".*" setting ()
    pre {
      a_form = <<
        <form id="my_form" onsubmit="return false">
          First Name: <input type="text" name="first"/>
          Last Name: <input type="text" name="last"/>
          <input type="submit" value="Submit"/>
        </form>
        >>;
    }
    append("#main", a_form);
    watch("#my_form", "submit");
  }
}




