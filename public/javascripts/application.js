jQuery(function($) {
    if ( $('ul.gallery').length ) {
    	$('ul.gallery').galleria( {
    		clickNext : true,
    		insert: "#photo_large",
    		onImage: function ( image, caption, thumb ) {
    			image.css('display','none').fadeIn()

    			thumb.parents('li').siblings().children('img.selected').fadeTo(500,0.3)
    			thumb.fadeTo('fast',1).addClass('selected')
    			$( '#photo_metadata' ).html( '<a href=\'/photos/' + thumb.attr('id').replace('thumb_', '') + '/edit\'>Update photo details</a>' )

    			var scrollable = $("#thumbstrip").scrollable()
    			scrollable.seekTo( thumb.parents('ul').children().index( thumb.parents('li') ) )
    		},
    		onThumb: function ( thumb) {
    			thumb.css({display:'none',opacity: (thumb.parents('li').is('.active') ? '1' : '0.3') }).fadeIn(1500)
    		}
    	})        
    }

	
	if ( $('#thumbstrip').length ) {
    	$('#thumbstrip').scrollable( {
    		items : '#thumbs',
    		clickable: true,
    		keyboard : false
    	})
	    if ( $('#thumbs li.active').length == 0 ){
		    //$('div.scrollable').scrollable().click(0)
		    $('#thumbs li:first').addClass('active')
	    }
	}
    if ( $('#photo_tag_list').length ) {
        $('#photo_tag_list').tagSuggest({
          tags: $('#all_tags').val().split('\'')
        })
    }

	//$('div.scrollable').scrollable().click( $('#gallery ul').children().index( $('#gallery li.active') ) )
});