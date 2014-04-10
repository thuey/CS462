ruleset givingStreamWeb {
  meta {
    name "GivingStreamWeb"
    description <<
      The web listener for GivingStream
    >>
    author ""
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
    givingStreamUrl = "http://ec2-54-80-167-106.compute-1.amazonaws.com/";
    eventChannel = "931D8D36-BEC9-11E3-B492-8C2563A358EB";
    rids = "b505205x9";
    myZipcode = "84604";
  }

  rule initialize {
    select when pageview ".*"
    pre {
      my_html = <<
        <div id="form_wrapper"></div>
        <div id="display_wrapper"></div>
      >>;
    }
    every {
      append("#main", my_html);
      /*
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("GivingStream", {}, my_html);
      */
    }
  }

  rule show_form {
    select when pageview ".*"
    pre {
      a_form = <<
        <form id="my_form" onsubmit="return false">
          <input type="text" name="command"/>
          <input type="submit" value="Submit"/>
        </form>
        >>;
    }
    {
      replace_inner("#form_wrapper", a_form);
      watch("#my_form", "submit");
    }
  }

  rule show_alerts {
    select when pageview ".*"
    foreach ent:alerts setting (alert)
    pre {
      location = alert.pick("$.location");
      tag = alert.pick("$.tag");
      description = alert.pick("$.description");
      imageURL = alert.pick("$.imageURL");
      test = ent:test || "";
      content = <<
        <p>Location: #{location}</p>
        <p>Tag: #{tag}</p>
        <p>Description: #{description}</p>
        <p>Image URL: #{imageURL}</p>
        <p>Test: #{test}</p>
      >>;
    }
    replace_inner("#display_wrapper", content);
  }

  rule respond_submit {
    select when web submit "#my_form"
    pre {
      body = event:attr("command");
      bodyArray = body.split(re/ /);
      command = bodyArray[0].lc();
    }
    if (userId) then {
      noop();
    }
    fired {
      set ent:test body;
      raise explicit event command
        with body = body;
    }
    else {
      set ent:test body;
      raise explicit event getUserId
        with body = body
          and command = command;
    }
  }

  rule getUserId {
    select when explicit getUserId
    pre {
      command = event:attr("command");
      body = event:attr("body");
      result = http:post(givingStreamUrl + "users");
      content = result.pick("$.content").decode();
      userId = content.pick("$.id").as("str");
    }
    always {
      set ent:userId userId;
      raise explicit event command
        with body = body;
    }
  }

  rule offer {
    select when explicit offer
    pre {
      userId = ent:userId;
      body = event:attr("body");
      tags = body.extract(re/ #(\w+)\s?/);
      zipcode = body.extract(re/ z(\d+)\s?/);

      description = body.replace(re/ #\w+\s?/, "");
      description = description.replace(re/ z\d+\s?/, "");
    }
    {
      send_directive("test") with hello = userId;
      http:post(givingStreamUrl + "offers")
        with body = {
          "location" : zipcode,
          "tag" : tags,
          "description" : description
        } and
        headers = {
          "content-type": "application/json"
        };
    }
  }
  
  rule watch {
    select when explicit watch
    pre {
      userId = ent:userId;
      body = event:attr("body");
      tags = body.extract(re/ #(\w+)\s?/);
      webhook = "https://cs.kobj.net/sky/event/"+eventChannel+"?_domain=givingStream&_name=watchTagAlert&_rids="+rids;
    }
    {
      send_directive("testing") with tags = tags and webhook = webhook and userId = userId;
      http:post(givingStreamUrl + "users/" + userId + "/watchtags")
        with body = {
          "watchtags" : tags,
          "webhook" : webhook
        } and
        headers = {
          "content-type": "application/json"
        };
    }
  }
  
  rule stopWatching {
    select when explicit stopwatching
    pre {
      userId = ent:userId;
      body = event:attr("body");
      tags = body.extract(re/ #(\w+)\s?/);
      submitBody = tags.length() > 0 => {"watchtags" : tags} | {};
    }
    {
      send_directive("stopped") with submitBody = submitBody;
      http:delete(givingStreamUrl + "users/" + userId + "/watchtags")
        with body = submitBody and
        headers = {
          "content-type": "application/json"
        };
    }
  }

  rule watchTagAlert {
    select when givingStream watchTagAlert
    pre {
      content = event:attr("offer");
      contentDecoded = content.decode();
      location = contentDecoded.pick("$.location").as("str");
      tag = contentDecoded.pick("$.tag").as("str");
      description = contentDecoded.pick("$.description").as("str");
      imageURL = contentDecoded.pick("$.imageURL").as("str");
    }
    if (location == myZipcode) then
    {
      twilio:send_sms("8017094212", "3852194414", tag + " " + description + " " + imageURL);
    }
  }
  
  rule watchTagAlert {
    select when givingStream watchTagAlert
    pre {
      content = event:attr("offer");
      contentDecoded = content.decode();
      location = contentDecoded.pick("$.location").as("str");
      tag = contentDecoded.pick("$.tag").as("str");
      description = contentDecoded.pick("$.description").as("str");
      imageURL = contentDecoded.pick("$.imageURL").as("str");
      alerts = ent:alerts || [];
      newAlert = {
        "location": location,
        "tag": tag,
        "description": description,
        "imageURL": imageURL
      };
      newAlerts = alerts.append(newAlert);
    }
    if (location == myZipcode) then
    {
      noop();
    }
    fired {
      set ent:alerts newAlerts;
    }
  }
}