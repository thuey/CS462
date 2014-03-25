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
    subscription_maps = [
      {
        'cid' : 'EB50BF16-B0B2-11E3-B443-97291F48CFDD'
      },
      {
        'cid' : '3458C14A-B0B3-11E3-BCC7-7F291F48CFDD'
      }
    ];
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
      lat = checkinDecoded.pick("$..venue").pick("$..lat");
      lng = checkinDecoded.pick("$..venue").pick("$..lng");
    }
    send_directive("venue name") with checkin = venue;
    always {
      set ent:checkin checkin;
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:createdAt createdAt;
      set ent:lat lat;
      set ent:lng lng;
      raise pds event 'new_location_data' 
        with key = "fs_checkin"
          and value = {
            "venue" : venue,
            "city"  : city,
            "shout" : shout,
            "createdAt" : createdAt,
            "lat" : lat,
            "lng" : lng
          };
    }
  }

  rule dispatcher {
    select when foursquare checkin
    foreach subscription_maps setting (subscription_map)
    pre {
      checkin = ent:checkin;
      venue = ent:venue;
      city = ent:city;
      shout = ent:shout;
      createdAt = ent:createdAt;
      location_data = {
          "checkin" : checkin,
          "venue" : venue,
          "city"  : city,
          "shout" : shout,
          "createdAt" : createdAt
         }
    }
    every {
      send_directive("testing") with bob = {
          "checkin" : checkin,
          "venue" : venue,
          "city"  : city,
          "shout" : shout,
          "createdAt" : createdAt
         };
      event:send(subscription_map, "location", "notification")
        with location_data = {
          "checkin" : checkin,
          "venue" : venue,
          "city"  : city,
          "shout" : shout,
          "createdAt" : createdAt
         }
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
