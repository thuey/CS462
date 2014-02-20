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
      result = http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json", {
          "apikey":"u9enwznpee6pweaucdmf54p8",
          "q":movie_title.replace(re/ /, "%20"),
          "page_limit":"1"
        }
      );
      result.pick("$.content").decode()
    }
  }
  
  rule initialize {
    select when pageview ".*" setting ()
    pre {
      form_wrapper = <<
        <div id="form_wrapper"></div>
      >>;
      display_wrapper = <<
        <div id="display_wrapper"></div>
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
      submittedTitle = event:attr("title");
      results = movie_info(submittedTitle);
      total = results.pick("$.total");
      img_src = results.pick("$..thumbnail");
      title = results.pick("$..title");
      year = results.pick("$..year");
      synopsis = results.pick("$..synopsis");
      critics_rating = results.pick("$..critics_rating");
      audience_rating = results.pick("$..audience_rating");
      
      content = << 
        <img src="#{img_src}" />
        <p>Title: #{title}</p>
        <p>Release Year: #{year}</p>
        <p>Synopsis: #{synopsis}</p>
        <p>Critics Rating: #{critics_rating}</p>
        <p>Audience Rating: #{audience_rating}</p>
      >>;
      sorry = <<
        <p>Sorry, no results were found for #{submittedTitle}</p>
      >>;
      printout = total == 0 => sorry | content;
    }
    replace_inner("#display_wrapper", "#{printout}");
  }
}














