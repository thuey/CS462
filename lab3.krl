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
          <input type="text" name="first"/>
          <input type="text" name="last"/>
          <input type="submit" value="Submit"/>
        </form>
        >>;
      p = <<
        <p id="name"></p>
      >>;
    }
    if (true) then {
      append("#main", a_form);
      append("#main", p);
      watch("#my_form", "submit");
    }
  }
  rule respond_submit {
    select when web submit "#my_form"
    pre {
      firstname = event:attr("first");
      lastname = event:attr("last");
      name = firstname + " " + lastname;
    }
    replace_inner("#name",  "#{name}"); 
    always {
      set ent:firstname firstname;
      set ent:lastname lastname;
    }
  }
  rule print_names {
    select when pageview ".*" setting ()
    pre {
      firstName = ent:firstname;
      lastName = ent:lastname;
      name = firstName + " " + lastName;
    }
    if (firstName && lastName) then
      replace_inner("#name", "#{name}"); 
  }
}



