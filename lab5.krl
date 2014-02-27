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
  rule initialize {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id="mainAppDiv">Hello</div>
      >>;
    }
    {
     SquareTag:inject_styling();
     CloudRain:createLoadPanel("Lab 5", {}, my_html);
    }
  }
  rule process_fs_checkin {
    select when foursquare checkin
    pre {
      checkin = event:attr("checkin");
      venue = event:attr("test");
      city = event:attr("city");
      shout = event:attr("shout");
      createdAt = event:attr("createdAt");
      test = event:attr("test");
    }
    always {
      set ent:checkin checkin;
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:createdAt createdAt;
      set ent:test test;
    }
  }
  
  rule display_checkin {
    select when web cloudAppSelected
    pre {
      checkin = ent:checkin;
      venue = ent:venue;
      city = ent:city;
      shout = ent:shout;
      createdAt = ent:createdAt;
      test = ent:test;
      
      content = << 
        <p>Test: #{test}</p>
        <p>Checkin: #{checkin}</p>
        <p>Venue: #{venue}</p>
        <p>City: #{city}</p>
        <p>Shout: #{shout}</p>
        <p>Created At: #{createdAt}</p>
      >>;
    }
    replace_inner("#mainAppDiv", "#{content}");
  }
}
