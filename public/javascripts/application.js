jQuery(function($) {
  
    if ( $('.tag_list').length ) {
        $('.tag_list').tagSuggest({
          tags: $('#all_tags').val().split('\'')
        })
    }

    var map, locations_on_map = new Array();    
    if ( $('#map_canvas').length && $('#album_latitude').val() > '' && $('#album_longitude').val() > '' ) {
	    mapInitialize()
	    $('#map_canvas').show()
	}
	
	$("#album_address").change( function () {
	        var geocoder = new GClientGeocoder()
	        //console.log( $("#album_address").val() )
	        geocoder.getLatLng(  $("#album_address").val()  , function(point) {
	                //console.log( point )
	                if ( point ) {
	                    if (typeof map == "undefined") {
                	        $('#map_canvas').show()
                	        mapInitialize()
                	    }
                	    
	                    $('#album_latitude').val( point.lat() )
	                    $('#album_longitude').val( point.lng() )
	                    map.setCenter(new GLatLng( $('#album_latitude').val(), $('#album_longitude').val()), 13);
    	                var marker = mapCreateMarker( { 'title' : $("#album_title").val(), 'address' : $("#album_address").val(), 'latitude': point.lat(), 'longitude' : point.lng() } );
                        map.addOverlay(marker);
                    }
                    else
                    {
                        $('#map_canvas').hide()
        	        }
	            }
	        )
	    }
	)
    
    function mapInitialize() {
      if (GBrowserIsCompatible()) {
        map = new GMap2(document.getElementById("map_canvas"));
        map.setUIToDefault();
        map.setCenter(new GLatLng( $('#album_latitude').val(), $('#album_longitude').val()), 13);
        var marker = mapCreateMarker( { 'id' : $("#album_id").val(), 'title' : $("#album_title").val(), 'address' : $("#album_address").val(), 'latitude': $("#album_latitude").val(), 'longitude' : $("#album_longitude").val() } );
        map.addOverlay(marker);
        map.setCenter( new GLatLng( $("#album_latitude").val(), $("#album_longitude").val() ), 13   )
        locations_on_map[ $("#album_id").val() ][0].openInfoWindowHtml( locations_on_map[ $("#album_id").val() ][1] )
      }
    }
    
    function mapProcessData(data) {
        var locations = eval('(' + data + ')');
        for (var i=0; i<locations.length; i++) {
            var marker = mapCreateMarker(locations[i].location )
            if ( marker ) {
                map.addOverlay( marker )
            }
        }
    }
    
    function mapCreateMarker(location) {
        if ( !location.latitude || !location.longitude ) {
            return false;
        }
        var marker = new GMarker( new GLatLng(parseFloat( location.latitude), parseFloat( location.longitude) ) )
        var html = "<b>" + location.title + "</b> <br/>" + location.address + "<br /><br/>"
        locations_on_map[location.id] = [marker, html]
        GEvent.addListener(marker, 'click', function() {
            marker.openInfoWindowHtml(html);
        });
        return marker
    }

	//$('div.scrollable').scrollable().click( $('#gallery ul').children().index( $('#gallery li.active') ) )
});