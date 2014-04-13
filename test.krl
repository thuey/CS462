ruleset test {
  meta {
    name "Test"
    description <<
      Test
    >>
    author ""
  }
  dispatch {
  }
  global {
    
  }

  rule test {
    select when test raiser
    pre {

    }
    send_directive("test") with raiser = "raiser";
    always {
      raise explicit event 'listener';
    }
  }

  rule listener {
    select when explicit listener
    pre {

    }
    send_directive("test") with listener = "listener";
  }

}
