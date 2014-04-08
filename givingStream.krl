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
    givingStreamUrl = "ec2-54-80-167-106.compute-1.amazonaws.com/";
  }

  rule getUserId {
    select when explicit getUserId
    pre {
      command = event:attr("command");
      body = event:attr("body");
      result = http:post(givingStreamUrl + "users");
      userId = result.pick("$.id").as("str");
    }
    send_directive("getuserId") with userId = userId;
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
      body = event:attr("Body");
      bodyArray = body.split(re/ /);
      command = bodyArray[0].lc();
    }
    if (userId) then {
      send_directive("receiveCommand") with command = command;
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
    }
  }

  rule watch {
    select when explicit watch
    pre {
      body = event:attr("body");
    }
  }

  rule watchTagAlert {
    select when givingStream watchTagAlert
    pre {

    }
  }
}
