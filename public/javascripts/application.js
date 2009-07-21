jQuery(function($) {
  
    if ( $('.tag_list').length ) {
        $('.tag_list').tagSuggest({
          tags: $('#all_tags').val().split('\'')
        })
    }

    var map, latlng    
    if ( $('#map_canvas').length && $('#album_latitude').val() > '' && $('#album_longitude').val() > '' ) {
        latlng = new google.maps.LatLng($('#album_latitude').val(), $('#album_longitude').val());
	    mapInitialize()
	    $('#map_canvas').show()
	}
    if ( $('#map_canvas').length && $('#photo_latitude').val() > '' && $('#photo_longitude').val() > '' ) {
        latlng = new google.maps.LatLng($('#photo_latitude').val(), $('#photo_longitude').val());
	    mapInitialize()
	    $('#map_canvas').show()
	}

	$("#album_address").change( function() {
	    if( !map ) {
	        mapInitialize()
    	    $('#map_canvas').show()
	    }
	    var geocoder = new google.maps.Geocoder()
	    var address = this.value
            if (geocoder) {
              geocoder.geocode( { 'address': address}, function(results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                  if (status != google.maps.GeocoderStatus.ZERO_RESULTS) {
                    map.set_center(results[0].geometry.location)
                    mapCreateMarker( {
                        title: $('#album_title').val(),
                        address: results[0].formatted_address,
                        position: results[0].geometry.location
                        }
                    )
                  } else {
                    //alert("No results found")
                  }
                } else {
                  //alert("Geocode was not successful for the following reason: " + status)
                }
              });
            }
	})

	function mapInitialize() {
	    var myOptions = {
              zoom: 13,
              center: latlng,
              mapTypeId: google.maps.MapTypeId.ROADMAP
        }
        map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
	}
    
    function mapCreateMarker(location) {
        var marker = new google.maps.Marker({
            map: map, 
            position: location.position,
            title: location.title
        })
        
        var infowindow = new google.maps.InfoWindow({
                content: '<b>' + location.title + '</b><br/>' + location.address
            })

        google.maps.event.addListener(marker, 'click', function() {
              infowindow.open(map,marker)
        })
    }
    
})