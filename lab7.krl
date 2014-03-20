ruleset lab7 {
  meta {
    name "Lab7"
    description <<
      Lab 7
    >>
    author ""
    use module b505205x4 alias location_data
  }
  dispatch {
  }
  global {
    
  }
  
  rule nearby {
    select when location currents
    
    pre {
      lata = event:attr("lat");
      lnga = event:attr("lng");
      hashMap = location_data:get_location_data("fs_checkin");
      latb = hashMap{"lat"};
      lngb = hashMap{"lng"};

      r90   = math:pi()/2;      
      rEk   = 6378;         // radius of the Earth in km
       
      // convert co-ordinates to radians
      rlata = math:deg2rad(lata);
      rlnga = math:deg2rad(lnga);
      rlatb = math:deg2rad(latb);
      rlngb = math:deg2rad(lngb);
       
      // distance between two co-ordinates in kilometers
      dE = math:great_circle_distance(rlnga,r90 - rlata, rlngb,r90 - rlatb, rEk);
      
      // distance in miles:
      dM = dE*0.621371;
    }
    if (dM > 5) then {
      noop();
    }
    fired {
      raise explicit event "location_nearby"
        with distance = dM;
    }
    else {
      raise explicit event "location_far"
        with distance = dM;
    }
  }
}
