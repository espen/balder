jQuery(function($) {
  
    if ( $('.tag_list').length ) {
        $('.tag_list').tagSuggest({
          tags: $('#all_tags').val().split('\'')
        })
    }

	//$('div.scrollable').scrollable().click( $('#gallery ul').children().index( $('#gallery li.active') ) )
});