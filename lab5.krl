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
      checkinDecoded = checkin.decode();
      venue = checkinDecoded.pick("$..venue").pick("$.name").as("str");
      city = checkinDecoded.pick("$..venue").pick("$..city").as("str");
      shout = checkinDecoded.pick("$..shout").as("str");
      createdAt = checkinDecoded.pick("$..createdAt").as("str");
    }
    send_directive("venue name") with checkin = venue;
    always {
      set ent:checkin checkin;
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:createdAt createdAt;
      raise pds event 'new_location_data' 
        with key = "fs_checkin"
          and value = {
            "venue" : venue,
            "city"  : city,
            "shout" : shout,
            "createdAt" : createdAt
          };
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
      
      content = << 
        <p>Venue: #{venue}</p>
        <p>City: #{city}</p>
        <p>Shout: #{shout}</p>
        <p>Created At: #{createdAt}</p>
      >>;
    }
    replace_inner("#mainAppDiv", "#{content}");
  }
}
