ruleset examine_location {
  meta {
    name "Foursquare"
    description <<
      Foursquare
    >>
    author ""
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
    use module b505205x4 alias location_data
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
     CloudRain:createLoadPanel("Inspector", {}, my_html);
    }
  }

  rule show_fs_location {
    select when web cloudAppSelected
    pre {
      hashMap = location_data:get_location_data("fs_checkin");
      venue = hashMap{"venue"};
      city = hashMap{"city"};
      shout = hashMap{"shout"};
      createdAt = hashMap{"createdAt"};
      message = location_data:global_message;
      
      content = << 
        <p>Testing: #{message}</p>
        <p>Venue: #{venue}</p>
        <p>City: #{city}</p>
        <p>Shout: #{shout}</p>
        <p>Created At: #{createdAt}</p>
      >>;
    }
    replace_inner("#mainAppDiv", "#{content}");
  }
}
