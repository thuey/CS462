
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
        notify("Hello World", "My first notification.") with position = "top-left";
        notify("Hello World", "My second notification.") with position = "bottom-right";
    }
  }
}
