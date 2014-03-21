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
        <div id="mainAppDiv">Hello</div>
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
      location_data = event:attr('location_data');
      venue = location_data{'venue'};
      city = location_data{'city'};
      shout = location_data{'shout'};
      createdAt = location_data{'createdAt'};
    }
    always {
      set ent:venue venue;
      set ent:city city;
      set ent:shout shout;
      set ent:createdAt createdAt;
    }
  }
  
  rule location_show {
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
