ruleset rotten_tomatoes {
  meta {
    name "Rotten Tomatoes"
    description <<
      Rotten Tomatoes
    >>
    author ""
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
    movie_info = http:get("pi.rottentomatoes.com/api/public/v1.0.json",
               {"apikey": "u9enwznpee6pweaucdmf54p8"
               }
              );
  }

  rule show_form {
    select when pageview ".*" setting ()
    pre {
      a_form = <<
        <form id="my_form" onsubmit="return false">
          <input type="text" name="title"/>
          <input type="submit" value="Submit"/>
        </form>
        >>;
    }
    if (true) then {
      append("#main", a_form);
      watch("#my_form", "submit");
    }
  }
  
  rule respond_submit {
    select when web submit "#my_form"
    pre {
      title = event:attr("title");
    }
    replace_inner("#name",  "#{name}"); 
  }
}












