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
    provides get_location_data, global_message
  }
  dispatch {
  }
  global {
    get_location_data = function (k) {
      ent:hashMap{k};
    };
    global_message = function () { ent:bob };
  }

  rule add_location_item {
    select when pds new_location_data
    pre {
      eventKey = event:attr("keyvalue");
      eventValue = event:attr("value");
    }
    send_directive(eventKey) with location = eventValue;
    always {
      set ent:hashMap{event:attr("key")} event:attr("value");
      set ent:bob "hello world";
    }
  }
}
