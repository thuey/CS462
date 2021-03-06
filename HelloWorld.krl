ruleset HelloWorldApp {
  meta {
    name "Hello World"
    description <<
      Hello World
    >>
    author ""
    logging off
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
        <h5>Hello, World!</h5>
      >>;
    }
    {
     SquareTag:inject_styling();
     CloudRain:createLoadPanel("Hello World!", {}, my_html);
    }
  }
  
  rule first_rule {
    select when pageview ".*" setting ()
    every {
        notify("Hello World", "My first notification.") with position = "top-right";
        notify("Hello World", "My second notification.") with position = "bottom-right";
    }
  }

  rule second_rule {
    select when pageview ".*" setting ()
    pre {
      stringParser = function(query) {
          query.extract(re/name=(\w+)/);
        };
      query = page:url("query");
      matches = stringParser(query);
      text = matches[0] || "Monkey";
    }
    notify("Query", "Hello " + text) with position = "bottom-left";
  }

  rule third_rule {
    select when pageview ".*" setting()
    pre {
    }
    if ent:visitor_count < 5 then
      notify("Count", ent:visitor_count + 1) with position = "top-left";
    always {
      ent:visitor_count +=1 from 1;
    }
  }

  rule fourth_rule {
    select when pageview ".*" setting()
    pre {
      stringParser = function(query) {
          query.extract(re/(clear=)/);
        };
      query = page:url("query");
      matches = stringParser(query);
      text = matches[0] || "";
    }
    if (text eq "clear=") then {
      noop();
    }
    fired {
      clear ent:visitor_count;
    }
  }
}












