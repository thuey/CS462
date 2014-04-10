ruleset givingStreamWeb {
  meta {
    name "GivingStreamWeb"
    description <<
      The web listener for GivingStream
    >>
    author ""
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
  }

  rule initialize {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id="form_wrapper"></div>
        <div id="display_wrapper"></div>
      >>;
    }
    every {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("GivingStream", {}, my_html);
    }
  }

  rule show_form {
    select when web cloudAppSelected
    pre {
      a_form = <<
        <form id="my_form" onsubmit="location.reload()">
          <input type="text" name="command"/>
          <input type="submit" value="Submit"/>
        </form>
        >>;
    }
    {
      replace_inner("#form_wrapper", a_form);
      watch("#my_form", "submit");
    }
    always {
      set ent:test "whoa";
    }
  }
  
  rule respond_submit {
    select when web submit "#my_form"
    pre {
      
    }
    noop();
    fired {
      set ent:test "whoa";
    }
  }

  rule show_alerts {
    select when web cloudAppSelected
    pre {
      test = ent:test || "";
      content = <<
        <p>Test: #{test}</p>
      >>;
    }
    replace_inner("#display_wrapper", content);
  }

}