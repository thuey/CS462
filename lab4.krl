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
    movie_info = function(movie_title) { 
      http:get("http://pi.rottentomatoes.com/api/public/v1.0.json", {
          "apikey":"u9enwznpee6pweaucdmf54p8",
          "q":movie_title,
          "page_limit":10
        }
      );
    }
  }
  
  rule initialize {
    select when pageview ".*" setting ()
    pre {
      form_wrapper = <<
        <div id="form_wrapper"></div>
      >>;
      display_wrapper = <<
        <div id="display_wrapper"></div>
      >>;
    }
    every {
      append("#main", display_wrapper);
      append("#main", form_wrapper);
    }
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
      replace_inner("#form_wrapper", a_form);
      watch("#my_form", "submit");
    }
  }
  
  rule respond_submit {
    select when web submit "#my_form"
    pre {
      title = event:attr("title");
      results = movie_info(title);
      total = results.pick("$..total");
    }
    /* replace_inner("#display_wrapper",  "#{total}"); */
  }
}













