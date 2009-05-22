/*

	GalleryView - jQuery Content Gallery Plugin
	Author: 		Jack Anderson
	Version:		2.0 (May 5, 2009)
	Documentation: 	http://www.spaceforaname.com/galleryview/
	
	Please use this development script if you intend to make changes to the
	plugin code.  For production sites, please use jquery.galleryview-2.0-pack.js.
	
	See CHANGELOG.txt for a review of changes and LICENSE.txt for the applicable
	licensing information.


*/

//Global variable to check if window is already loaded
//Used for calling GalleryView after page has loaded
var window_loaded = false;
			
(function($){
	$.fn.galleryView = function(options) {
		var opts = $.extend($.fn.galleryView.defaults,options);
		
		var id;
		var iterator = 0;
		var item_count = 0;
		var slide_method;
		var theme_path;
		var paused = false;
		
		//Element dimensions
		var gallery_width;
		var gallery_height;
		var pointer_height;
		var pointer_width;
		var strip_width;
		var strip_height;
		var wrapper_width;
		var f_frame_width;
		var f_frame_height;
		var frame_caption_size = 20;
		var gallery_padding;
		var filmstrip_margin;
		var filmstrip_orientation;
		
		
		//Arrays used to scale frames and panels
		var frame_img_scale = new Object();
		var panel_img_scale = new Object();
		var img_h = new Object();
		var img_w = new Object();
		
		//Flag indicating whether to scale panel images
		var scale_panel_images = true;
		
		var panel_nav_displayed = false;
		
		//Define jQuery objects for reuse
		var j_gallery;
		var j_filmstrip;
		var j_frames;
		var j_frame_img_wrappers;
		var j_panels;
		var j_pointer;
		
		
/************************************************/
/*	Plugin Methods								*/
/************************************************/	

	//Transition from current item to item 'i'
		function showItem(i) {
			//Disable next/prev buttons until transition is complete
			$('.nav-next-overlay',j_gallery).unbind('click');
			$('.nav-prev-overlay',j_gallery).unbind('click');
			$('.nav-next',j_gallery).unbind('click');
			$('.nav-prev',j_gallery).unbind('click');
			j_frames.unbind('click');
			
			//Fade out all frames while fading in target frame
			if(opts.show_filmstrip) {
				j_frames.removeClass('current').find('img').stop().animate({
					'opacity':opts.frame_opacity
				},opts.transition_speed);
				j_frames.eq(i).addClass('current').find('img').stop().animate({
					'opacity':1.0
				},opts.transition_speed);
			}
			
			//If the gallery has panels and the panels should fade, fade out all panels while fading in target panel
			if(opts.show_panels && opts.fade_panels) {
				j_panels.fadeOut(opts.transition_speed).eq(i%item_count).fadeIn(opts.transition_speed,function(){
					if(!opts.show_filmstrip) {
						$('.nav-prev-overlay',j_gallery).click(showPrevItem);
						$('.nav-next-overlay',j_gallery).click(showNextItem);
						$('.nav-prev',j_gallery).click(showPrevItem);
						$('.nav-next',j_gallery).click(showNextItem);		
					}
				});
			}
			
			//If gallery has a filmstrip, handle animation of frames
			if(opts.show_filmstrip) {
				//Slide either pointer or filmstrip, depending on transition method
				if(slide_method=='strip') {
					//Stop filmstrip if it's currently in motion
					j_filmstrip.stop();
					
					if(filmstrip_orientation=='horizontal') {
						//Determine distance between pointer (eventual destination) and target frame
						var distance = getPos(j_frames[i]).left - (getPos(j_pointer[0]).left+(pointer_width/2)-(f_frame_width/2));
						var diststr = (distance>=0?'-=':'+=')+Math.abs(distance)+'px';
						
						//Animate filmstrip and slide target frame under pointer
						j_filmstrip.animate({
							'left':diststr
						},opts.transition_speed,opts.easing,function(){
							//Always ensure that there are a sufficient number of hidden frames on either
							//side of the filmstrip to avoid empty frames
							var old_i = i;
							if(i>item_count) {
								i = i%item_count;
								iterator = i;
								j_filmstrip.css('left','-'+((f_frame_width+opts.frame_gap)*i)+'px');
							} else if (i<=(item_count-strip_size)) {
								i = (i%item_count)+item_count;
								iterator = i;
								j_filmstrip.css('left','-'+((f_frame_width+opts.frame_gap)*i)+'px');
							}
							//If the target frame has changed due to filmstrip shifting,
							//Make sure new target frame has 'current' class and correct size/opacity settings
							if(old_i != i) {
								j_frames.eq(old_i).removeClass('current').find('img').css({
									'opacity':opts.frame_opacity
								});
								j_frames.eq(i).addClass('current').find('img').css({
									'opacity':1.0
								});
							}
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}
							
							//Enable navigation now that animation is complete
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					} else {
						//Determine distance between pointer (eventual destination) and target frame
						var distance = getPos(j_frames[i]).top - (getPos(j_pointer[0]).top+(pointer_height)-(f_frame_height/2));
						var diststr = (distance>=0?'-=':'+=')+Math.abs(distance)+'px';
						
						//Animate filmstrip and slide target frame under pointer
						j_filmstrip.animate({
							'top':diststr
						},opts.transition_speed,opts.easing,function(){
							//Always ensure that there are a sufficient number of hidden frames on either
							//side of the filmstrip to avoid empty frames
							var old_i = i;
							if(i>item_count) {
								i = i%item_count;
								iterator = i;
								j_filmstrip.css('top','-'+((f_frame_height+opts.frame_gap)*i)+'px');
							} else if (i<=(item_count-strip_size)) {
								i = (i%item_count)+item_count;
								iterator = i;
								j_filmstrip.css('top','-'+((f_frame_height+opts.frame_gap)*i)+'px');
							}
							//If the target frame has changed due to filmstrip shifting,
							//Make sure new target frame has 'current' class and correct size/opacity settings
							if(old_i != i) {
								j_frames.eq(old_i).removeClass('current').find('img').css({
									'opacity':opts.frame_opacity
								});
								j_frames.eq(i).addClass('current').find('img').css({
									'opacity':1.0
								});
							}
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}
							
							//Enable navigation now that animation is complete
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					}
				} else if(slide_method=='pointer') {
					//Stop pointer if it's currently in motion
					j_pointer.stop();
					//Get position of target frame
					var pos = getPos(j_frames[i]);
					
					if(filmstrip_orientation=='horizontal') {
						//Slide the pointer over the target frame
						j_pointer.animate({
							'left':(pos.left+(f_frame_width/2)-(pointer_width/2)+'px')
						},opts.transition_speed,opts.easing,function(){	
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}	
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					} else {//Slide the pointer over the target frame
						j_pointer.animate({
							'top':(pos.top+(f_frame_height/2)-(pointer_height)+'px')
						},opts.transition_speed,opts.easing,function(){	
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}	
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					}
				}
			
			}
		};
		
	//Find padding and border widths applied to element
	//If border is non-numerical ('thin','medium', etc) set to zero
		function extraWidth(el) {
			if(!el) return 0;
			if(el.length==0) return 0;
			el = el.eq(0);
			var ew = 0;
			ew += getInt(el.css('paddingLeft'));
			ew += getInt(el.css('paddingRight'));
			ew += getInt(el.css('borderLeftWidth'));
			ew += getInt(el.css('borderRightWidth'));
			return ew;
		}
	//Find padding and border heights applied to element
	//If border is non-numerical ('thin','medium', etc) set to zero
		function extraHeight(el) {
			if(!el) return 0;
			if(el.length==0) return 0;
			el = el.eq(0);
			var eh = 0;
			eh += getInt(el.css('paddingTop'));
			eh += getInt(el.css('paddingBottom'));
			eh += getInt(el.css('borderTopWidth'));
			eh += getInt(el.css('borderBottomWidth'));
			return eh;
		}
		
	//Halt transition timer, move to next item, restart timer
		function showNextItem() {
			
			$(document).stopTime("transition");
			if(++iterator==j_frames.length) {iterator=0;}
			showItem(iterator);
			if(!paused) {
				$(document).everyTime(opts.transition_interval,"transition",function(){
					showNextItem();
				});
			}
		};
		
	//Halt transition timer, move to previous item, restart timer
		function showPrevItem() {
			$(document).stopTime("transition");
			if(--iterator<0) {iterator = item_count-1;}
			showItem(iterator);
			if(!paused) {
				$(document).everyTime(opts.transition_interval,"transition",function(){
					showNextItem();
				});
			}
		};
		
	//Get absolute position of element in relation to top-left corner of gallery
	//If el=gallery, return position of gallery within browser viewport
		function getPos(el) {
			var left = 0, top = 0;
			var el_id = el.id;
			if(el.offsetParent) {
				do {
					left += el.offsetLeft;
					top += el.offsetTop;
				} while(el = el.offsetParent);
			}
			//If we want the position of the gallery itself, return it
			if(el_id == id) {return {'left':left,'top':top};}
			//Otherwise, get position of element relative to gallery
			else {
				var gPos = getPos(j_gallery[0]);
				var gLeft = gPos.left;
				var gTop = gPos.top;
				
				return {'left':left-gLeft,'top':top-gTop};
			}
		};
		
	//Add onclick event to each frame
		function enableFrameClicking() {
			j_frames.each(function(i){
				//If there isn't a link in this frame, set up frame to slide on click
				//Frames with links will handle themselves
				if($('a',this).length==0) {
					$(this).click(function(){
						if(iterator!=i) {
							$(document).stopTime("transition");
							showItem(i);
							iterator = i;
							if(!paused) {
								$(document).everyTime(opts.transition_interval,"transition",function(){
									showNextItem();
								});
							}
						}
					});
				}
			});
		};
		
	//Construct gallery panels from '.panel' <div>s
		function buildPanels() {
			//If there are panel captions, add overlay divs
			j_panels.each(function(i){
		   		if($('.panel-overlay',this).length>0) {
					$(this).append('<div class="overlay-background"></div>');	
				}
		   	});
			if(!opts.show_filmstrip) {
				//Add navigation buttons
				$('<img />').addClass('nav-next').attr('src',theme_path+opts.nav_theme+'/next.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1100',
					'cursor':'pointer',
					'top':((opts.panel_height-22)/2)+gallery_padding+'px',
					'right':'10px',
					'display':'none'
				}).click(showNextItem);
				$('<img />').addClass('nav-prev').attr('src',theme_path+opts.nav_theme+'/prev.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1100',
					'cursor':'pointer',
					'top':((opts.panel_height-22)/2)+gallery_padding+'px',
					'left':'10px',
					'display':'none'
				}).click(showPrevItem);
				
				$('<img />').addClass('nav-next-overlay').attr('src',theme_path+opts.nav_theme+'/panel-nav-next.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1099',
					'top':((opts.panel_height-22)/2)+gallery_padding-10+'px',
					'right':'0',
					'display':'none',
					'cursor':'pointer',
					'opacity':0.75
				}).click(showNextItem);
				
				$('<img />').addClass('nav-prev-overlay').attr('src',theme_path+opts.nav_theme+'/panel-nav-prev.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1099',
					'top':((opts.panel_height-22)/2)+gallery_padding-10+'px',
					'left':'0',
					'display':'none',
					'cursor':'pointer',
					'opacity':0.75
				}).click(showPrevItem);
			}
			j_panels.each(function(i){
				$(this).css({
					'width':(opts.panel_width-extraWidth(j_panels))+'px',
					'height':(opts.panel_height-extraHeight(j_panels))+'px',
					'position':'absolute',
					'overflow':'hidden',
					'display':'none'
				});
				switch(opts.filmstrip_position) {
					case 'top': $(this).css({
									'top':strip_height+Math.max(gallery_padding,filmstrip_margin)+'px',
									'left':gallery_padding+'px'
								}); break;
					case 'left': $(this).css({
								 	'top':gallery_padding+'px',
									'left':strip_width+Math.max(gallery_padding,filmstrip_margin)+'px'
								 }); break;
					default: $(this).css({'top':gallery_padding+'px','left':gallery_padding+'px'}); break;
				}
			});
			$('.panel-overlay',j_panels).css({
				'position':'absolute',
				'zIndex':'999',
				'width':(opts.panel_width-extraWidth($('.panel-overlay',j_panels)))+'px',
				'left':'0'
			});
			$('.overlay-background',j_panels).css({
				'position':'absolute',
				'zIndex':'998',
				'width':opts.panel_width+'px',
				'left':'0',
				'opacity':opts.overlay_opacity
			});
			if(opts.overlay_position=='top') {
				$('.panel-overlay',j_panels).css('top',0);
				$('.overlay-background',j_panels).css('top',0);
			} else {
				$('.panel-overlay',j_panels).css('bottom',0);
				$('.overlay-background',j_panels).css('bottom',0);
			}
			
			$('.panel iframe',j_panels).css({
				'width':opts.panel_width+'px',
				'height':opts.panel_height+'px',
				'border':'0'
			});
			
			if(scale_panel_images) {
				$('img',j_panels).each(function(i){
					$(this).css({
						'height':panel_img_scale[i%item_count]*img_h[i%item_count],
						'width':panel_img_scale[i%item_count]*img_w[i%item_count],
						'position':'relative',
						'top':(opts.panel_height-(panel_img_scale[i%item_count]*img_h[i%item_count]))/2+'px',
						'left':(opts.panel_width-(panel_img_scale[i%item_count]*img_w[i%item_count]))/2+'px'
					});
				});
			}
		};
		
	//Construct filmstrip from '.filmstrip' <ul>
		function buildFilmstrip() {
			//Add wrapper to filmstrip to hide extra frames
			j_filmstrip.wrap('<div class="strip_wrapper"></div>');
			if(slide_method=='strip') {
				j_frames.clone().appendTo(j_filmstrip);
				j_frames.clone().appendTo(j_filmstrip);
				j_frames = $('li',j_filmstrip);
			}
			//If captions are enabled, add caption divs and fill with the image titles
			if(opts.show_captions) {
				j_frames.append('<div class="caption"></div>').each(function(i){
					$(this).find('.caption').html($(this).find('img').attr('title'));	
					//$(this).find('.caption').html(i);		
				});
			}
			j_filmstrip.css({
				'listStyle':'none',
				'margin':'0',
				'padding':'0',
				'width':strip_width+'px',
				'position':'absolute',
				'zIndex':'900',
				'top':(filmstrip_orientation=='vertical' && slide_method=='strip'?-((f_frame_height+opts.frame_gap)*iterator):0)+'px',
				'left':(filmstrip_orientation=='horizontal' && slide_method=='strip'?-((f_frame_width+opts.frame_gap)*iterator):0)+'px',
				'height':strip_height+'px'
			});
			j_frames.css({
				'float':'left',
				'position':'relative',
				'height':f_frame_height+(opts.show_captions?frame_caption_size:0)+'px',
				'width':f_frame_width+'px',
				'zIndex':'901',
				'padding':'0',
				'cursor':'pointer'
			});
			switch(opts.filmstrip_position) {
				case 'top': j_frames.css({
								'marginBottom':filmstrip_margin+'px',
								'marginRight':opts.frame_gap+'px'
							}); break;
				case 'bottom': j_frames.css({
								'marginTop':filmstrip_margin+'px',
								'marginRight':opts.frame_gap+'px'
							}); break;
				case 'left': j_frames.css({
								'marginRight':filmstrip_margin+'px',
								'marginBottom':opts.frame_gap+'px'
							}); break;
				case 'right': j_frames.css({
								'marginLeft':filmstrip_margin+'px',
								'marginBottom':opts.frame_gap+'px'
							}); break;
			}
			$('.img_wrap',j_frames).each(function(i){								  
				$(this).css({
					'height':Math.min(opts.frame_height,img_h[i%item_count]*frame_img_scale[i%item_count])+'px',
					'width':Math.min(opts.frame_width,img_w[i%item_count]*frame_img_scale[i%item_count])+'px',
					'position':'relative',
					'top':(opts.show_captions && opts.filmstrip_position=='top'?frame_caption_size:0)+Math.max(0,(opts.frame_height-(frame_img_scale[i%item_count]*img_h[i%item_count]))/2)+'px',
					'left':Math.max(0,(opts.frame_width-(frame_img_scale[i%item_count]*img_w[i%item_count]))/2)+'px',
					'overflow':'hidden'
				});
			});
			$('img',j_frames).each(function(i){
				$(this).css({
					'opacity':opts.frame_opacity,
					'height':img_h[i%item_count]*frame_img_scale[i%item_count]+'px',
					'width':img_w[i%item_count]*frame_img_scale[i%item_count]+'px',
					'position':'relative',
					'top':Math.min(0,(opts.frame_height-(frame_img_scale[i%item_count]*img_h[i%item_count]))/2)+'px',
					'left':Math.min(0,(opts.frame_width-(frame_img_scale[i%item_count]*img_w[i%item_count]))/2)+'px'
	
				}).mouseover(function(){
					$(this).stop().animate({'opacity':1.0},300);
				}).mouseout(function(){
					//Don't fade out current frame on mouseout
					if(!$(this).parent().parent().hasClass('current')) $(this).stop().animate({'opacity':opts.frame_opacity},300);
				});
			});
			$('.strip_wrapper',j_gallery).css({
				'position':'absolute',
				'overflow':'hidden'
			});
			if(filmstrip_orientation=='horizontal') {
				$('.strip_wrapper',j_gallery).css({
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin)+'px':opts.panel_height+gallery_padding+'px'),
					'left':((gallery_width-wrapper_width)/2)+gallery_padding+'px',
					'width':wrapper_width+'px',
					'height':strip_height+'px'
				});
			} else {
				$('.strip_wrapper',j_gallery).css({
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin)+'px':opts.panel_width+gallery_padding+'px'),
					'top':Math.max(gallery_padding,opts.frame_gap)+'px',
					'width':strip_width+'px',
					'height':wrapper_height+'px'
				});
			}
			$('.caption',j_gallery).css({
				'position':'absolute',
				'top':(opts.filmstrip_position=='bottom'?f_frame_height:0)+'px',
				'left':'0',
				'margin':'0',
				'width':f_frame_width+'px',
				'padding':'0',
				'height':frame_caption_size+'px',
				'overflow':'hidden',
				'lineHeight':frame_caption_size+'px'
			});
			var pointer = $('<div></div>');
			pointer.addClass('pointer').appendTo(j_gallery).css({
				 'position':'absolute',
				 'zIndex':'1000',
				 'width':'0px',
				 'fontSize':'0px',
				 'lineHeight':'0%',
				 'borderTopWidth':pointer_height+'px',
				 'borderRightWidth':(pointer_width/2)+'px',
				 'borderBottomWidth':pointer_height+'px',
				 'borderLeftWidth':(pointer_width/2)+'px',
				 'borderStyle':'solid'
			});
			
			//For IE6, use predefined color string in place of transparent (see stylesheet)
			var transColor = $.browser.msie && $.browser.version.substr(0,1)=='6' ? 'pink' : 'transparent'
			
			if(!opts.show_panels) { pointer.css('borderColor',transColor); }
		
				switch(opts.filmstrip_position) {
					case 'top': pointer.css({
									'bottom':(opts.panel_height-(pointer_height*2)+gallery_padding+filmstrip_margin)+'px',
				 					'left':((gallery_width-wrapper_width)/2)+(slide_method=='strip'?0:((f_frame_width+opts.frame_gap)*iterator))+((f_frame_width/2)-(pointer_width/2))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderRightColor':transColor,
									'borderLeftColor':transColor
								}); break;
					case 'bottom': pointer.css({
										'top':(opts.panel_height-(pointer_height*2)+gallery_padding+filmstrip_margin)+'px',
				 						'left':((gallery_width-wrapper_width)/2)+(slide_method=='strip'?0:((f_frame_width+opts.frame_gap)*iterator))+((f_frame_width/2)-(pointer_width/2))+gallery_padding+'px',
										'borderTopColor':transColor,
										'borderRightColor':transColor,
										'borderLeftColor':transColor
									}); break;
					case 'left': pointer.css({
									'right':(opts.panel_width-pointer_width+gallery_padding+filmstrip_margin)+'px',
				 					'top':(f_frame_height/2)-(pointer_height)+(slide_method=='strip'?0:((f_frame_height+opts.frame_gap)*iterator))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderRightColor':transColor,
									'borderTopColor':transColor
								}); break;
					case 'right': pointer.css({
									'left':(opts.panel_width-pointer_width+gallery_padding+filmstrip_margin)+'px',
				 					'top':(f_frame_height/2)-(pointer_height)+(slide_method=='strip'?0:((f_frame_height+opts.frame_gap)*iterator))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderLeftColor':transColor,
									'borderTopColor':transColor
								}); break;
				}
		
			j_pointer = $('.pointer',j_gallery);
			
			//Add navigation buttons
			var navNext = $('<img />');
			navNext.addClass('nav-next').attr('src',theme_path+opts.nav_theme+'/next.gif').appendTo(j_gallery).css({
				'position':'absolute',
				'cursor':'pointer'
			}).click(showNextItem);
			var navPrev = $('<img />');
			navPrev.addClass('nav-prev').attr('src',theme_path+opts.nav_theme+'/prev.gif').appendTo(j_gallery).css({
				'position':'absolute',
				'cursor':'pointer'
			}).click(showPrevItem);
			if(filmstrip_orientation=='horizontal') {
				navNext.css({					 
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin):opts.panel_height+filmstrip_margin+gallery_padding)+((f_frame_height-22)/2)+'px',
					'right':((gallery_width+(gallery_padding*2))/2)-(wrapper_width/2)-opts.frame_gap-22+'px'
				});
				navPrev.css({
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin):opts.panel_height+filmstrip_margin+gallery_padding)+((f_frame_height-22)/2)+'px',
					'left':((gallery_width+(gallery_padding*2))/2)-(wrapper_width/2)-opts.frame_gap-22+'px'
				 });
			} else {
				navNext.css({					 
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin):opts.panel_width+filmstrip_margin+gallery_padding)+((f_frame_width-22)/2)+13+'px',
					'top':wrapper_height+(Math.max(gallery_padding,opts.frame_gap)*2)+'px'
				});
				navPrev.css({
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin):opts.panel_width+filmstrip_margin+gallery_padding)+((f_frame_width-22)/2)-13+'px',
					'top':wrapper_height+(Math.max(gallery_padding,opts.frame_gap)*2)+'px'
				});
			}
		};
		
	//Check mouse to see if it is within the borders of the panel
	//More reliable than 'mouseover' event when elements overlay the panel
		function mouseIsOverGallery(x,y) {		
			var pos = getPos(j_gallery[0]);
			var top = pos.top;
			var left = pos.left;
			return x > left && x < left+gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin)) && y > top && y < top+gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin));				
		};
		
		function getInt(i) {
			i = parseInt(i,10);
			if(isNaN(i)) { i = 0; }
			return i;	
		}
					
		function buildGallery() {
			var gallery_images = opts.show_filmstrip?$('img',j_frames):$('img',j_panels);
			gallery_images.each(function(i){
				img_h[i] = this.height;
				img_w[i] = this.width;
				if(opts.frame_scale=='nocrop') {
					frame_img_scale[i] = Math.min(opts.frame_height/img_h[i],opts.frame_width/img_w[i]);
				} else {
					frame_img_scale[i] = Math.max(opts.frame_height/img_h[i],opts.frame_width/img_w[i]);
				}
				
				if(opts.panel_scale=='nocrop') {
					panel_img_scale[i] = Math.min(opts.panel_height/img_h[i],opts.panel_width/img_w[i]);
				} else {
					panel_img_scale[i] = Math.max(opts.panel_height/img_h[i],opts.panel_width/img_w[i]);
				}
			});
	
	/************************************************/
	/*	Apply CSS Styles							*/
	/************************************************/
			j_gallery.css({
				'position':'relative',
				'width':gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px',
				'height':gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px'
			});
	
	/************************************************/
	/*	Build filmstrip and/or panels				*/
	/************************************************/
			if(opts.show_filmstrip) {
				buildFilmstrip();
				enableFrameClicking();
			}
			if(opts.show_panels) {
				buildPanels();
			}

	/************************************************/
	/*	Add events to various elements				*/
	/************************************************/
			if(opts.pause_on_hover || (opts.show_panels && !opts.show_filmstrip)) {
				$().mousemove(function(e){							
					if(mouseIsOverGallery(e.pageX,e.pageY)) {
						if(opts.pause_on_hover) {
							if(!paused) {
								$(document).oneTime(500,"animation_pause",function(){
									$(document).stopTime("transition");
									paused=true;
								});
							}
						}
						if(opts.show_panels && !opts.show_filmstrip && !panel_nav_displayed) {
							$('.nav-next-overlay').fadeIn('fast');
							$('.nav-prev-overlay').fadeIn('fast');
							$('.nav-next',j_gallery).fadeIn('fast');
							$('.nav-prev',j_gallery).fadeIn('fast');
							panel_nav_displayed = true;
						}
					} else {
						if(opts.pause_on_hover) {
							$(document).stopTime("animation_pause");
							if(paused) {
								$(document).everyTime(opts.transition_interval,"transition",function(){
									showNextItem();
								});
								paused = false;
							}
						}
						if(opts.show_panels && !opts.show_filmstrip && panel_nav_displayed) {
							$('.nav-next-overlay').fadeOut('fast');
							$('.nav-prev-overlay').fadeOut('fast');
							$('.nav-next',j_gallery).fadeOut('fast');
							$('.nav-prev',j_gallery).fadeOut('fast');
							panel_nav_displayed = false;
						}
					}
				});
			}
	
	
	/****************************************************************/
	/*	Initiate Automated Animation								*/
	/****************************************************************/
			
			//Hide loading box
			j_filmstrip.css('visibility','visible');
			j_gallery.css('visibility','visible');
			$('.loader',j_gallery).fadeOut('1000',function(){
				//Show the 'first' panel
				showItem(iterator);
				//If we have more than one item, begin automated transitions
				if(item_count > 1) {
					$(document).everyTime(opts.transition_interval,"transition",function(){
						showNextItem();
					});
				}	
			});	
		}
		
/************************************************/
/*	Main Plugin Code							*/
/************************************************/
		return this.each(function() {
			//Hide <ul>
			$(this).css('visibility','hidden');
			
			//Wrap <ul> in <div> and transfer ID to container <div>
			//Assign filmstrip class to <ul>
			$(this).wrap("<div></div>");
			j_gallery = $(this).parent();
			j_gallery.css('visibility','hidden').attr('id',$(this).attr('id')).addClass('gallery');
			$(this).removeAttr('id').addClass('filmstrip');
			
			$(document).stopTime("transition");
			$(document).stopTime("animation_pause");
			
			id = j_gallery.attr('id');
			
			//If there is no defined panel content, we will scale panel images
			scale_panel_images = $('.panel-content',j_gallery).length==0;
			
			//Define dimensions of pointer <div>
			pointer_height = opts.pointer_size;
			pointer_width = opts.pointer_size*2;
			
			//Determine filmstrip orientation (vertical or horizontal)
			//Do not show captions on vertical filmstrips
			filmstrip_orientation = (opts.filmstrip_position=='top'||opts.filmstrip_position=='bottom'?'horizontal':'vertical');
			if(filmstrip_orientation=='vertical') opts.show_captions = false;
			
			//Determine path between current page and plugin images
			//Scan script tags and look for path to GalleryView plugin
			$('script').each(function(i){
				var s = $(this);
				if(s.attr('src') && s.attr('src').match(/jquery\.galleryview/)){
					loader_path = s.attr('src').split('jquery.galleryview')[0];
					theme_path = s.attr('src').split('jquery.galleryview')[0]+'themes/';	
				}
			});
			
			j_filmstrip = $('.filmstrip',j_gallery);
			j_frames = $('li',j_filmstrip);
			j_frames.addClass('frame');
			
			//If the user wants panels, generate them using the filmstrip images
			if(opts.show_panels) {
				for(i=j_frames.length-1;i>=0;i--) {
					if(j_frames.eq(i).find('.panel-content').length>0) {
						j_frames.eq(i).find('.panel-content').remove().prependTo(j_gallery).addClass('panel');
					} else {
						p = $('<div>');
						p.addClass('panel');
						im = $('<img />');
						im.attr('src',j_frames.eq(i).find('img').eq(0).attr('src')).appendTo(p);
						p.prependTo(j_gallery);
						j_frames.eq(i).find('.panel-overlay').remove().appendTo(p);
					}
				}
			} else { 
				$('.panel-overlay',j_frames).remove(); 
				$('.panel-content',j_frames).remove();
			}
			
			//If the user doesn't want a filmstrip, delete it
			if(!opts.show_filmstrip) { j_filmstrip.remove(); }
			else {
				//Wrap the frame images (and links, if applicable) in container divs
				//These divs will handle cropping and zooming of the images
				j_frames.each(function(i){
					if($(this).find('a').length>0) {
						$(this).find('a').wrap('<div class="img_wrap"></div>');
					} else {
						$(this).find('img').wrap('<div class="img_wrap"></div>');	
					}
				});
				j_frame_img_wrappers = $('.img_wrap',j_frames);
			}
			
			j_panels = $('.panel',j_gallery);
			
			if(!opts.show_panels) {
				opts.panel_height = 0;
				opts.panel_width = 0;
			}
			
			
			//Determine final frame dimensions, accounting for user-added padding and border
			f_frame_width = opts.frame_width+extraWidth(j_frame_img_wrappers);
			f_frame_height = opts.frame_height+extraHeight(j_frame_img_wrappers);
			
			//Number of frames in filmstrip
			item_count = opts.show_panels?j_panels.length:j_frames.length;
			
			//Number of frames that can display within the gallery block
			//64 = width of block for navigation button * 2 + 20
			if(filmstrip_orientation=='horizontal') {
				strip_size = opts.show_panels?Math.floor((opts.panel_width-((opts.frame_gap+22)*2))/(f_frame_width+opts.frame_gap)):Math.min(item_count,opts.filmstrip_size); 
			} else {
				strip_size = opts.show_panels?Math.floor((opts.panel_height-(opts.frame_gap+22))/(f_frame_height+opts.frame_gap)):Math.min(item_count,opts.filmstrip_size);
			}
			
			/************************************************/
			/*	Determine transition method for filmstrip	*/
			/************************************************/
					//If more items than strip size, slide filmstrip
					//Otherwise, slide pointer
					if(strip_size >= item_count) {
						slide_method = 'pointer';
						strip_size = item_count;
					}
					else {slide_method = 'strip';}
					
					iterator = (strip_size<item_count?item_count:0)+opts.start_frame-1;
			
			/************************************************/
			/*	Determine dimensions of various elements	*/
			/************************************************/
					filmstrip_margin = (opts.show_panels?getInt(j_filmstrip.css('marginTop')):0);
					j_filmstrip.css('margin','0px');
					
					if(filmstrip_orientation=='horizontal') {
						//Width of gallery block
						gallery_width = opts.show_panels?opts.panel_width:(strip_size*(f_frame_width+opts.frame_gap))+44+opts.frame_gap;
						
						//Height of gallery block = screen + filmstrip + captions (optional)
						gallery_height = (opts.show_panels?opts.panel_height:0)+(opts.show_filmstrip?f_frame_height+filmstrip_margin+(opts.show_captions?frame_caption_size:0):0);
					} else {
						//Width of gallery block
						gallery_height = opts.show_panels?opts.panel_height:(strip_size*(f_frame_height+opts.frame_gap))+22;
						
						//Height of gallery block = screen + filmstrip + captions (optional)
						gallery_width = (opts.show_panels?opts.panel_width:0)+(opts.show_filmstrip?f_frame_width+filmstrip_margin:0);
					}
					
					
					
					//Width of filmstrip
					if(filmstrip_orientation=='horizontal') {
						if(slide_method == 'pointer') {strip_width = (f_frame_width*item_count)+(opts.frame_gap*(item_count));}
						else {strip_width = (f_frame_width*item_count*3)+(opts.frame_gap*(item_count*3));}
					} else {
						strip_width = (f_frame_width+filmstrip_margin);
					}
					
					if(filmstrip_orientation=='horizontal') {
						strip_height = (f_frame_height+filmstrip_margin+(opts.show_captions?frame_caption_size:0));	
					} else {
						if(slide_method == 'pointer') {strip_height = (f_frame_height*item_count+opts.frame_gap*(item_count));}
						else {strip_height = (f_frame_height*item_count*3)+(opts.frame_gap*(item_count*3));}
					}
					
					//Width of filmstrip wrapper (to hide overflow)
					wrapper_width = ((strip_size*f_frame_width)+((strip_size-1)*opts.frame_gap));
					wrapper_height = ((strip_size*f_frame_height)+((strip_size-1)*opts.frame_gap));

					
					gallery_padding = getInt(j_gallery.css('paddingTop'));
					j_gallery.css('padding','0px');
			/********************************************************/
			/*	PLACE LOADING BOX OVER GALLERY UNTIL IMAGES LOAD	*/
			/********************************************************/
					galleryPos = getPos(j_gallery[0]);
					$('<div>').addClass('loader').css({
						'position':'absolute',
						'zIndex':'32666',
						'opacity':1,
						'top':'0px',
						'left':'0px',
						'width':gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px',
						'height':gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px'
					}).appendTo(j_gallery);
					
			
			if(!window_loaded) {
				$(window).load(function(){
					window_loaded = true;
					buildGallery();
				});
			} else {
				buildGallery();
			}
					
		});
	};
	
	$.fn.galleryView.defaults = {
		
		show_panels: true,
		show_filmstrip: true,
		
		panel_width: 600,
		panel_height: 400,
		frame_width: 60,
		frame_height: 40,
		
		start_frame: 1,
		filmstrip_size: 3,
		transition_speed: 800,
		transition_interval: 4000,
		
		overlay_opacity: 0.7,
		frame_opacity: 0.3,
		
		pointer_size: 8,
		
		nav_theme: 'dark',
		easing: 'swing',
		
		filmstrip_position: 'bottom',
		overlay_position: 'bottom',
		
		panel_scale: 'nocrop',
		frame_scale: 'crop',
		
		frame_gap: 5,
		
		show_captions: false,
		fade_panels: true,
		pause_on_hover: false
	};
})(jQuery);