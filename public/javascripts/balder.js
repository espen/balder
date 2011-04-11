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
	
	$('#collection_albums .delete').live('click', function() {
	    $(this).parent('span').fadeOut('slow', function() { $(this).remove() })
	})
	
	$("#available_albums").change( function() {
	    if ( this.value == '' ) {
	        return false
	    }
	    else if ( $('#collection_album_list_' + this.value).length ) {
	        $('#collection_album_list_' + this.value).parent('span').fadeTo('slow', 0.33, function () {
	            $(this).fadeTo('slow', 1)
	        })
	        return false
	    }
	    $.getJSON("/albums/" + this.value + '/photos',
                function(data){
                    console.log( data[0].photo.file.album.url );
                    html = '<span style="display:none;"><img src="/images/delete-24x24.png" border="" class="delete" />'
                    html += '<img alt="' + $("#available_albums :selected").val()  + '_collection" src=' + data[0].photo.file.album.url + ' />'
                    html += '<input id="collection_album_list_' + $("#available_albums :selected").val()  + '" name="collection[album_list][' + $("#available_albums :selected").val()  + ']" type="hidden" />'
                    html += '</span>'
                    $('#collection_albums').append(html)
                    $('#collection_album_list_' + $('#available_albums :selected').val() ).parent('span').fadeIn('slow')
                })
	}
	)

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