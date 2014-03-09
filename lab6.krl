ruleset location_data {
  meta {
    name "Lab 6"
    description <<
      Lab 6
    >>
    author ""
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
    provides get_location_data
  }
  dispatch {
  }
  global {
    get_location_data = function (k) {
      ent:hashMap{k};
    };
  }
  /*
  rule initialize {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id="mainAppDiv">Hello</div>
      >>;
    }
    {
     SquareTag:inject_styling();
     CloudRain:createLoadPanel("Lab 6", {}, my_html);
    }
  }
  */

  rule add_location_item {
    select when pds new_location_data
    pre {
      eventKey = event:attr("key");
      eventValue = event:attr("value");
      hashMap = {};
      hashMap = hashMap.put([eventKey], eventValue);
    }
    always {
      set ent:hashMap hashMap;
    }
  }
}
