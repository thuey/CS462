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
    
  }
  rule receiveCommand {
    select when twilio command
    pre {
    
    }
  }

  rule watchTagAlert {
    select when givingStream watchTagAlert
    pre {

    }
  }
}
