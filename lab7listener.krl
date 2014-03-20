ruleset lab7listener {
  meta {
    name "Lab7Listener"
    description <<
      Lab 7 Listener
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
    
  }
  rule listener {
    select when location_nearby
    twilio:send_sms("8017094212", "3852194414", event:attr("distance"));
  }
}
