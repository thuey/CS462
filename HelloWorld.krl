
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
      text = stringParser(query) || "Monkey";
    }
    notify("Query", "Hello" + text) with position = "bottom-left";
  }
}












