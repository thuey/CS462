ruleset lab7listener {
  meta {
    name "Lab7Listener"
    description <<
      Lab 7 Listener
    >>
    author ""
  }
  dispatch {
  }
  global {
    
  }
  rule listener {
    select when location nearby
  }
}
