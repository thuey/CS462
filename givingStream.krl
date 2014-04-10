ruleset givingStream {
  meta {
    name "GivingStream"
    description <<
      The listener for GivingStream
    >>
    author ""

    key twilio {"account_sid" : "ACad13df656e7828ae5cbc95e1a786b744",
                "auth_token"  : "0a11406796224bad4fecf997d926fa48"
    }
     
    use module a8x115 alias twilio with twiliokeys = keys:twilio()
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
    select when twilio command
    pre {
      userId = ent:userId;
      body = event:attr("body");
      bodyArray = body.split(re/ /);
      command = bodyArray[0].lc();
    }
    if (userId) then {
      send_directive("called") with called = userId;
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
      webhook = "http://cs.kobj.net/sky/event/"+eventChannel+"?_domain=givingStream&_name=watchTagAlert&_rids="+rids;
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
        with body = {} and
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
      tags = contentDecoded.pick("$.tags").join(" ");
      description = contentDecoded.pick("$.description").as("str");
      imageURL = contentDecoded.pick("$.imageURL").as("str");
    }
    //if (location == myZipcode) then
    {
      send_directive("testContent") with testing = "Tags: " + tags + ". Description: " + description + " Image: " + imageURL;
      //twilio:send_sms("8017094212", "3852194414", tag + " " + description + " " + imageURL);
    }
  }
}