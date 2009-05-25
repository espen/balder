/**
 * jquery.scrollable 1.0.2. Put your HTML scroll.
 * 
 * Copyright (c) 2009 Tero Piirainen
 * http://flowplayer.org/tools/scrollable.html
 *
 * Dual licensed under MIT and GPL 2+ licenses
 * http://www.opensource.org/licenses
 *
 * Launch  : March 2008
 * Version : 1.0.2 - Tue Feb 24 2009 10:52:08 GMT-0000 (GMT+00:00)
 */
(function($) {
		
	function fireEvent(opts, name, self, arg) {
		var fn = opts[name];
		
		if ($.isFunction(fn)) { 
			try {  
				return fn.call(self, arg);
				
			} catch (error) {
				if (opts.alert) {
					alert("Error calling scrollable." + name + ": " + error);
				} else {
					throw error;	
				}
				return false;
			} 					
		}
		return true;			
	}
				
	var current = null;	
	
	
	// constructor
	function Scrollable(root, conf) {   
				
		// current instance
		var self = this;  
		if (!current) { current = self; }		
		
		// horizontal flag
		var horizontal = !conf.vertical;		
		
		
		// wrap (root elements for items)
		var wrap = $(conf.items, root);				
		
		// current index
		var index = 0;
		
		
		// get handle to navigational elements
		var navi = root.siblings(conf.navi).eq(0);
		var prev = root.siblings(conf.prev).eq(0);
		var next = root.siblings(conf.next).eq(0);
		var prevPage = root.siblings(conf.prevPage).eq(0);
		var nextPage = root.siblings(conf.nextPage).eq(0);
		
		
		// methods
		$.extend(self, {
				
			getVersion: function() {
				return [1, 0, 1];	
			},
			
			getIndex: function() {
				return index;	
			},
	
			getConf: function() {
				return conf;	
			},
			
			getSize: function() {
				return self.getItems().size();	
			},
	
			getPageAmount: function() {
				return Math.ceil(this.getSize() / conf.size); 	
			},
			
			getPageIndex: function() {
				return Math.ceil(index / conf.size);	
			},

			getRoot: function() {
				return root;	
			},
			
			getItemWrap: function() {
				return wrap;	
			},
			
			getItems: function() {
				return wrap.children();	
			},
			
			/* all seeking functions depend on this */		
			seekTo: function(i, time, fn) {
				
				// default speed
				time = time || conf.speed;
				
				// function given as second argument
				if ($.isFunction(time)) {
					fn = time;
					time = conf.speed;
				}
								
				if (i < 0) { i = 0; }				
				if (i > self.getSize() - conf.size) { return self; } 				

				var item = self.getItems().eq(i);					
				if (!item.length) { return self; }				
				
				// onBeforeSeek
				if (fireEvent(conf, "onBeforeSeek", self, i) === false) {
					return self;	
				}									
				
				if (horizontal) {					
					var left = -(item.outerWidth(true) * i);					
					wrap.animate({left: left}, time, conf.easing, fn ? function() { fn.call(self); } : null);
					
				} else {
					var top = -(item.outerHeight(true) * i); // wrap.offset().top - item.offset().top;					
					wrap.animate({top: top}, time, conf.easing, fn ? function() { fn.call(self); } : null);							
				}	
				
				
				// navi status update
				if (navi.length) {
					var klass = conf.activeClass;
					var page = Math.ceil(i / conf.size);
					page = Math.min(page, navi.children().length - 1);
					navi.children().removeClass(klass).eq(page).addClass(klass);
				} 
				
				// prev buttons disabled flag
				if (i === 0) {
					prev.add(prevPage).addClass(conf.disabledClass);					
				} else {
					prev.add(prevPage).removeClass(conf.disabledClass);
				}
								
				// next buttons disabled flag
				if (i >= self.getSize() - conf.size) {
					next.add(nextPage).addClass(conf.disabledClass);
				} else {
					next.add(nextPage).removeClass(conf.disabledClass);
				}				
				
				current = self;
				index = i;				
				
				// onSeek after index being updated
				fireEvent(conf, "onSeek", self, i);	
				
				return self;
				
			},			
				
			move: function(offset, time, fn) {
				var to = index + offset;
				if (conf.loop && to > (self.getSize() - conf.size)) {
					to = 0;	
				}
				return this.seekTo(to, time, fn);
			},
			
			next: function(time, fn) {
				return this.move(1, time, fn);	
			},
			
			prev: function(time, fn) {
				return this.move(-1, time, fn);	
			},
			
			movePage: function(offset, time, fn) {
				return this.move(conf.size * offset, time, fn);		
			},
			
			setPage: function(page, time, fn) {
				var size = conf.size;
				var index = size * page;
				var lastPage = index + size >= this.getSize(); 
				if (lastPage) {
					index = this.getSize() - conf.size;
				}
				return this.seekTo(index, time, fn);
			},
			
			prevPage: function(time, fn) {
				return this.setPage(this.getPageIndex() - 1, time, fn);
			},  
	
			nextPage: function(time, fn) {
				return this.setPage(this.getPageIndex() + 1, time, fn);
			}, 
			
			begin: function(time, fn) {
				return this.seekTo(0, time, fn);	
			},
			
			end: function(time, fn) {
				return this.seekTo(this.getSize() - conf.size, time, fn);	
			},
			
			reload: function() {
				return load();	
			},
			
			click: function(index, time, fn) {
				
				var item = self.getItems().eq(index);
				var klass = conf.activeClass;			
				
				if (!item.hasClass(klass) && (index >= 0 || index < this.getSize())) {				
					self.getItems().removeClass(klass);
					item.addClass(klass);
					var delta = Math.floor(conf.size / 2);
					var to = index - delta;

					// next to last item must work
					if (to > self.getSize() - conf.size) { to--;	}
					
					if (to !== index) {
						return this.seekTo(to, time, fn);		
					}				 
				}
				
				return self;
			}			
			
		});
	
		
		// mousewheel
		if ($.isFunction($.fn.mousewheel)) { 
			root.bind("mousewheel.scrollable", function(e, delta)  {
				// opera goes to opposite direction
				var step = $.browser.opera ? 1 : -1;
				
				self.move(delta > 0 ? step : -step, 50);
				return false;
			});
		}  
		
		// prev button		
		prev.addClass(conf.disabledClass).click(function() { 
			self.prev(); 
		});
		

		// next button
		next.click(function() { 
			self.next(); 
		});
		
		// prev page button
		nextPage.click(function() { 
			self.nextPage(); 
		});
		

		// next page button
		prevPage.addClass(conf.disabledClass).click(function() { 
			self.prevPage(); 
		});		

		
		// keyboard
		if (conf.keyboard) {
			
			// unfortunately window.keypress does not work on IE.
			$(window).unbind("keypress.scrollable").bind("keypress.scrollable", function(evt) {
				
				var el = current;	
				if (!el) { return; }
					
				if (horizontal && (evt.keyCode == 37 || evt.keyCode == 39)) {					
					el.move(evt.keyCode == 37 ? -1 : 1);
					return evt.preventDefault();
				}	
				
				if (!horizontal && (evt.keyCode == 38 || evt.keyCode == 40)) {
					el.move(evt.keyCode == 38 ? -1 : 1);
					return evt.preventDefault();
				}
				
				return true;
				
			});	 
		}

		// navi 			
		function load() {			
			
			navi.each(function() {
				
				var nav = $(this);
				
				// generate new entries
				if (nav.is(":empty") || nav.data("me") == self) {
					
					nav.empty();
					nav.data("me", self);
					
					for (var i = 0; i < self.getPageAmount(); i++) {		
						
						var item = $("<" + conf.naviItem + "/>").attr("href", i).click(function(e) {							
							var el = $(this);
							el.parent().children().removeClass(conf.activeClass);
							el.addClass(conf.activeClass);
							self.setPage(el.attr("href"));
							return e.preventDefault();
						});
						
						if (i === 0) { item.addClass(conf.activeClass); }
						nav.append(item);					
					}
					
				// assign onClick events to existing entries
				} else {
					
					// find a entries first -> syntaxically correct
					var els = nav.children(); 
					
					els.each(function(i)  {
						var item = $(this);
						item.attr("href", i);
						if (i === 0) { item.addClass(conf.activeClass); }
						
						item.click(function() {
							nav.find("." + conf.activeClass).removeClass(conf.activeClass);
							item.addClass(conf.activeClass);
							self.setPage(item.attr("href"));
						});
						
					});
				}
				
			});
			
			
			// item.click()
			if (conf.clickable) {
				self.getItems().each(function(index, arg) {
					var el = $(this);
					if (!el.data("set")) {
						el.bind("click.scrollable", function() {
							self.click(index);		
						});
						el.data("set", true);
					}
				});				
			}
			
			
			// hover
			if (conf.hoverClass) {
				self.getItems().hover(function()  {
					$(this).addClass(conf.hoverClass);		
				}, function() {
					$(this).removeClass(conf.hoverClass);	
				});
			}			
			
			return self;
		}
		
		load();
		
		
		// interval stuff
		var timer = null;

		function setTimer() {
			timer = setInterval(function()  {
				self.next();
				
			}, conf.interval);	
		}	
		
		if (conf.interval > 0) {			
			
			root.hover(function() {			
				clearInterval(timer);		
			}, function() {		
				setTimer();	
			});
			
			setTimer();	
		}
		
	} 

		
	// jQuery plugin implementation
	jQuery.prototype.scrollable = function(conf) { 
			
		// already constructed --> return API
		var api = this.eq(typeof conf == 'number' ? conf : 0).data("scrollable");
		if (api) { return api; }		
		
 
		var opts = {
			
			// basics
			size: 5,
			vertical:false,			
			clickable: true,
			loop: false,
			interval: 0,			
			speed: 400,
			keyboard: true,			
			
			// other
			activeClass:'active',
			disabledClass: 'disabled',
			hoverClass: null,			
			easing: 'swing',
			
			// navigational elements
			items: '.items',
			prev: '.prev',
			next: '.next',
			prevPage: '.prevPage',
			nextPage: '.nextPage',			
			navi: '.navi',
			naviItem: 'a',

			
			// callbacks
			onBeforeSeek: null,
			onSeek: null,
			alert: true
		}; 
		
		
		$.extend(opts, conf);		
		
		this.each(function() {			
			var el = new Scrollable($(this), opts);
			$(this).data("scrollable", el);	
		});
		
		return this; 
		
	};
			
	
})(jQuery);
