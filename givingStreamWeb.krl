ruleset givingStreamWeb {
  meta {
    name "GivingStreamWeb"
    description <<
      The web listener for GivingStream
    >>
    author ""
    }
  }
  dispatch {
  }
  global {
    givingStreamUrl = "http://ec2-54-80-167-106.compute-1.amazonaws.com/";
    eventChannel = "931D8D36-BEC9-11E3-B492-8C2563A358EB";
    rids = "b505205x9";
    myZipcode = "84604";
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

  rule receiveCommand {
    select when app command
    pre {
      userId = ent:userId;
      body = event:attr("body");
      bodyArray = body.split(re/ /);
      command = bodyArray[0].lc();
    }
    if (userId) then {
      noop();
    }
    fired {
      raise explicit event command
        with body = body;
    }
    else {
      raise explicit event getUserId
        with body = body
          and command = command;
    }
  }

  rule offer {
    select when explicit offer
    pre {
      body = event:attr("body");
      tags = body.extract(re/ #(\w+) /);
      zipcode = body.extract(re/ z(\d+) /);

      description = body.replace(re/ #\w+ /, "");
      description = description.replace(re/ z\d+ /, "");
    }
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
  
  rule watch {
    select when explicit watch
    pre {
      body = event:attr("body");
      tags = body.extract(re/ #(\w+) /);
      webhook = "https://cs.kobj.net/sky/event/"+eventChannel+"?_domain=givingStream&_name=watchTagAlert&_rids="+rids;
    }
    http:post(givingStreamUrl + "users/" + userId + "/watchtags")
      with body = {
        "watchtags" : tags,
        "webhook" : webhook
      } and
      headers = {
        "content-type": "application/json"
      };
  }
  
  rule stop {
    select when explicit stop
    pre {
      body = event:attr("body");
      tags = body.extract(re/ #(\w+) /);
      webhook = "https://cs.kobj.net/sky/event/"+eventChannel+"?_domain=givingStream&_name=watchTagAlert&_rids="+rids
    }
    http:delete(givingStreamUrl + "users/" + userId + "/watchtags")
      with body = {
        "watchtags" : tags
      } and
      headers = {
        "content-type": "application/json"
      };
  }
  
  rule watchTagAlert {
    select when givingStream watchTagAlert
    pre {
      location = data.pick("$.location").as("str");
      tag = data.pick("$.tag").as("str");
      description = data.pick("$.tag").as("str");
      imageURL = data.pick("$.imageURL").as("str");
    }
    if (location == myZipcode) then
    {

    }
  }
  
}