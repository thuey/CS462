ruleset lab8 {
  meta {
    name "Lab8"
    description <<
      Lab 8
    >>
    author ""
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
        <div id="mainAppDiv">Hello2</div>
      >>;
    }
    {
     SquareTag:inject_styling();
     CloudRain:createLoadPanel("Lab 8", {}, my_html);
    }
  }
  
  rule location_catch {
    select when location notification
    pre {
      venue = event:attr("venue");
      city = event:attr("city");
      shout = event:attr("shout");
      createdAt = event:attr("createdAt");
    }
    always {
      set ent:location_data {
        "venue" : venue,
        "city"  : city,
        "shout" : shout,
        "createdAt" : createdAt
      }
    }
  }
  
  rule location_show {
    select when web cloudAppSelected
    pre {
      venue = ent:location_data{"venue"};
      city = ent:location_data{"city"};
      shout = ent:location_data{"shout"};
      createdAt = ent:location_data{"createdAt"};
      
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
