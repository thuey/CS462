ruleset foursquare {
  meta {
    name "Foursquare"
    description <<
      Foursquare
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
  
  rule process_fs_checkin {
    select when foursquare checkin
    pre {
      venue = event:attr("venue");
      city = event:attr("city");
      shout = event:attr("shout");
      createdAt = event:attr("createdAt");
    }
    always {
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:createdAt createdAt;
    }
  }
  
  rule display_checkin {
    select when foursquare checkin
  }
}
