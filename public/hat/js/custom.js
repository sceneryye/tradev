jQuery(function($){

	"use strict";

	/*---------------------------------------------------------------------------------*/
	/*  Global Values
	/*---------------------------------------------------------------------------------*/

	var $window = $(window),
		$body = $('body'),
		$header = $('.ss-header'),
		$logo = $('.ss-logo'),
		$welcome_text = $('.ss-welcome-text'),
		viewport_width = $window.width(),
		viewport_height = $window.height(),
		preloader_switch = 'on',
		$preloader = $('.ss-preloader'),
		preloader_delay = 0.6,
		is_mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

	// Update necessary global vars
    function update_viewport_vars() {
		viewport_width = $(window).width();
		viewport_height = $(window).height();
	}
	var _update_viewport_vars = _.throttle(update_viewport_vars, 100);
	$window.resize(_update_viewport_vars);


	/*---------------------------------------------------------------------------------*/
    /*	Preloader Init
	/*---------------------------------------------------------------------------------*/

	if ( preloader_switch == 'on' ) {

		var body_imageLoader = imagesLoaded('body');
		body_imageLoader.on('always', function (instance) {
    		TweenLite.to( $preloader.children(), 0.6, { css: { opacity: 0, scale: 0.01 }, ease: Expo.easeIn, delay: 0 });
    		TweenLite.to( $preloader, 0, { css: { opacity: 0, display: 'none' }, ease: Expo.easeIn, delay: 0.6 });
    		TweenLite.from( $('.ss-articles-wrap'), 0.6, { css: { opacity: 0, x: -30 }, ease: Expo.easeOut, delay: 1 });
    		TweenLite.from( $('.ss-sidebar'), 0.6, { css: { opacity: 0, x: 200 }, ease: Expo.easeOut, delay: 1 });
        });

	}


	/*---------------------------------------------------------------------------------*/
	/*  Header
	/*---------------------------------------------------------------------------------*/
	
	var nav_hover_interval = '';

	// Navigation Hover
	$('.ss-main-nav li').hover( function() {

		$(this).addClass('ss-hover');

		// Reveal Elements
		var reveal_index = 0,
        $reveal_elements = $(this).children('ul').children('li'),
        reveal_elements_size = $reveal_elements.size();

        nav_hover_interval = setInterval( function(index) {
        	if (reveal_index <= reveal_elements_size) {  // Making sure loop doesn't go crazy!
	            var $elem = $reveal_elements.eq(reveal_index);
	            TweenLite.to( $elem, 0, { css: { x: -60, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
	            TweenLite.to( $elem, 0.4, { css: { x: 0, opacity: 1 }, ease: Power3.easeOut, delay: 0 } );
	            if ( ++reveal_index > reveal_elements_size ) clearInterval(nav_hover_interval);
        	}
        }, 100);

	}, function() {
		clearInterval(nav_hover_interval)
		$(this).removeClass('ss-hover');
		TweenLite.to( $(this).children('ul').children('li'), 0.2, { css: { x: 30, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
	});

	

	// Menu Button
	var is_menu_open = false;
	$('.ss-menu-button.ss-open').on('click', function(event) {

		event.preventDefault();
		
		if ( is_menu_open ) {

			$(this).removeClass('ss-close').addClass('ss-open');

			var reveal_index = 0,
	        $reveal_elements = $(this).closest('.ss-header').find('.ss-main-nav').children('li'),
	        reveal_elements_size = $reveal_elements.size();
	        var interval = setInterval( function(index) {
	            var $elem = $reveal_elements.eq(reveal_index);
	            TweenLite.to( $elem, 0.2, { css: { x: 30, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
	            if ( ++reveal_index > reveal_elements_size ) {
	            	TweenLite.to( $welcome_text, 0, { css: { x: -30, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
	            	TweenLite.to( $welcome_text, 0.4, { css: { x: 0, opacity: 1 }, ease: Power3.easeOut, delay: 0 } );
	            	clearInterval(interval);
	            }
	        }, 100);

	        is_menu_open = false;

		} else {

			var $this = $(this);
			$(this).removeClass('ss-open').addClass('ss-close');
			TweenLite.to( $welcome_text, 0.2, { css: { x: 30, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
			
			setTimeout(function() {
				$('.ss-main-nav-container').css({
					display: 'block',
					opacity: '1'
				});

				var reveal_index = 0,
		        $reveal_elements = $this.closest('.ss-header').find('.ss-main-nav').children('li'),
		        reveal_elements_size = $reveal_elements.size();
		        var interval = setInterval( function(index) {
		            var $elem = $reveal_elements.eq(reveal_index);
		            TweenLite.to( $elem, 0, { css: { x: -30, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
		            TweenLite.to( $elem, 0.2, { css: { x: 0, opacity: 1 }, ease: Power3.easeOut, delay: 0 } );
		            if ( ++reveal_index > reveal_elements_size ) clearInterval(interval);
		        }, 100);
			}, 200);

			is_menu_open = true;

		}

	});


	/*---------------------------------------------------------------------------------*/
	/*  Header In Inner Pages
	/*---------------------------------------------------------------------------------*/

	var _update_header_pos = _.throttle(function() {
		if ( $('.ss-blog-wrap .ss-header').length > 0 && viewport_width > 1280 ) {
			var window_scroll = $window.scrollTop();
			if ( window_scroll > 30 ) {
				TweenLite.to( $('.ss-blog-wrap .ss-header .ss-header-inner'), 0.6, { css: { top: window_scroll }, ease: Power3.easeOut, delay: 0.1 } );
			} else {
				TweenLite.to( $('.ss-blog-wrap .ss-header .ss-header-inner'), 0.6, { css: { top: 0 }, ease: Power3.easeOut, delay: 0.1 } );
			}
		}
	}, 100);
	$window.scroll(_update_header_pos);
	_update_header_pos();



	/*---------------------------------------------------------------------------------*/
	/*  Tiles Masonry
	/*---------------------------------------------------------------------------------*/

    // Isotope Masonry
	var porfolio_loader = imagesLoaded( $('.ss-portfolio-wrap') );
	porfolio_loader.on('always', function (instance) {

		// Init Isotope
		$('.ss-portfolio-wrap').isotope({
			resizable: false,
			transitionDuration: 0,
			itemSelector: '.ss-tile',
			stamp: '.ss-header',
			// percentPosition: true,
	        masonry: {
	        	columnWidth: 1,
	        	gutter: 0,
				layoutMode: 'masonry',
	        },
	    });

		// Relayout Isotope
		setTimeout( function() {
			$('.ss-portfolio-wrap').isotope('layout');
		}, 100);

		// Reveal Elements
		setTimeout( function() {
			TweenLite.to( $header, 0, { css: { x: -30, scale: 1, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
	        TweenLite.to( $header, 0.5, { css: { x: 0, scale: 1, opacity: 1 }, ease: Power2.easeOut, delay: 0 } );
	        setTimeout( function() {
				var reveal_index = 0,
		        $reveal_elements = $('.ss-portfolio-wrap').find('.ss-tile'),
		        reveal_elements_size = $reveal_elements.size();
		        var interval = setInterval( function() {
		            var $elem = $reveal_elements.eq(reveal_index);
		            TweenLite.to( $elem, 0, { css: { scale: 0.9, y: -60, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
		            TweenLite.to( $elem, 0.4, { css: { scale: 1, y: 0, opacity: 1 }, ease: Power2.easeOut, delay: 0 } );
		            if ( ++reveal_index > reveal_elements_size ) clearInterval(interval);
		        }, 50);
	    	}, 200);
    	}, preloader_delay * 1000);
	    
	});

	
	/*---------------------------------------------------------------------------------*/
	/*  Tiles
	/*---------------------------------------------------------------------------------*/

	// Tile 4 - Latest News
	if ( $('.ss-latest-news-wrap').length ) {

		// Options
	    var latest_news_options = {
	    	horizontal: true,
			itemNav: 'forceCentered',
			smart: 1,
			activateMiddle: 1,
			mouseDragging: 0,
			touchDragging: 1,
			releaseSwing: 1,
			startAt: 0,
			scrollBy: 0,
			speed: 300,
			elasticBounds: 0,
			easing: 'easeOutExpo',
			dragHandle: 1,
			dynamicHandle: 1,
			clickBar: 1,
			cycleBy: 'pages',
			cycleInterval: 5000,
			pauseOnHover:  1,
	    };

	    // Get required variables
	    var $latest_news = $('.ss-latest-news-wrap'),
		latest_news_sly = [];

		// Loop through every Latest News Tile in the page
		$latest_news.each( function(index) {

			// Init Sly
			var $this =  $(this);
			latest_news_sly[index] = new Sly($this, latest_news_options).init();

			// Update Sly on Window Resize
			var _update_latest_news_sly = _.throttle(function() {
				$this.find('.ss-latest-news-item').css('width', function() {
					return $this.closest('.ss-latest-news-wrap').width() + 'px';
				});
				latest_news_sly[index].destroy().init()
			}, 900);
			$window.resize(_update_latest_news_sly);
			_update_latest_news_sly();

		});

	}

	
	/*------------------------------------------------------------------*/
    /*   Tiles Load More
    /*------------------------------------------------------------------*/

    var $portfolio = $('.ss-portfolio-wrap'),
    	portfolio_options = '',
    	portfolio_loading = '',
    	loadmore_button_txt = '',
    	done_txt = 'Done',
    	portfolio_posts_count = '',
    	portfolio_load_count = 0,
    	portfolio_per_page = 5;

    var portfolio_ajax = function() {
    	$.ajax({
	        type       : "GET",
	        dataType   : "html",
	        url        : 'index-ajax.html',
	        cache      : false,
	        success    : function(data) {

	            var $data = $(data).find('.ss-tile');
	            portfolio_posts_count = $data.length;  // Store Blog Posts Count
	            $data = $data.slice(portfolio_load_count, portfolio_load_count + portfolio_per_page);
	            if ( portfolio_load_count == portfolio_posts_count ) {
	            	$data.length = 0;
	            }

	            // If ther was any post
	            if ( $data.length ) {

	            	portfolio_load_count = portfolio_load_count + $data.length;
	                $data.hide().appendTo($portfolio);
	                var imageLoader = imagesLoaded( $portfolio );
	                imageLoader.on( 'always', function( instance ) {
	                    $portfolio.isotope( 'appended', $data );
	                    $portfolio.isotope('layout');
	                    $data.removeClass('ss-ajax');
	                    $data.waypoint(function (direction) {
					    	var reveal_index = 0,
					        $reveal_elements = $data,
					        reveal_elements_size = $reveal_elements.size();
					        var interval = setInterval( function() {
					            var $elem = $reveal_elements.eq(reveal_index);
					            TweenLite.to( $elem, 0, { css: { scale: 0.9, y: -60, opacity: 0 }, ease: Power3.easeOut, delay: 0 } );
					            TweenLite.to( $elem, 0.4, { css: { scale: 1, y: 0, opacity: 1 }, ease: Power2.easeOut, delay: 0 } );
					            if ( ++reveal_index > reveal_elements_size ) clearInterval(interval);
					        }, 50);
						}, { offset: "90%", triggerOnce: true }); 
	                    $('.ss-load-more').removeClass('ss-loading').text(loadmore_button_txt);
	                    portfolio_loading = false;
	                });

	            } else {

	                $('.ss-load-more').removeClass('ss-loading').text(done_txt);
	                setTimeout( function() {
	                	$('.ss-load-more').addClass('fadeOutUp');
	                }, 2000);
	            }

	        },
	        error     : function(jqXHR, textStatus, errorThrown) {
	            console.log(jqXHR + " :: " + textStatus + " :: " + errorThrown);
	            $('.ss-load-more').text('Error! Check the console for more information.');
	        }
	    });
    }
    

	$('.ss-load-more').on('click', function(e) {

		e.preventDefault();

        // Pre Init
        loadmore_button_txt = $(this).text();
        $(this).text('Loading...');
        $(this).addClass('ss-loading');
        portfolio_loading = true;

        // AJAX Call
        portfolio_ajax();

    });


	/*------------------------------------------------------------------*/
    /*   Portfolio Single
    /*------------------------------------------------------------------*/

    //  Portfolio Single Slider
    $(".single-portfolio .royalSlider").royalSlider({
        loop: true,
        autoHeight: true,
        // autoScaleSlider: true,
        imageScaleMode: 'fill',
        imageAlignCenter: false,
        slidesSpacing: 0,
        arrowsNav: true,
        controlNavigation: 'none',
        keyboardNavEnabled: true,
        arrowsNavAutoHide: true,
        sliderDrag: true,
        usePreloader: true,
        imageScalePadding: 0,
        transitionType: 'fade',
        transitionSpeed: 400,
    });

    // Portfolio Single Masonry
	var masonry_gallery = imagesLoaded( $('.ss-masonry-gallery') );
	masonry_gallery.on('always', function (instance) {

		// Init Isotope
		$('.ss-masonry-gallery').isotope({
			resizable: false,
			transitionDuration: 0,
			itemSelector: '.ss-masonry-gallery-item',
			// percentPosition: true,
	        masonry: {
	        	columnWidth: 1,
	        	gutter: 0,
				layoutMode: 'masonry',
	        },
	    });

		// Relayout Isotope
		setTimeout( function() {
			$('.ss-masonry-gallery').isotope('layout');
		}, 100);

	    
	});


	/*------------------------------------------------------------------*/
    /*   Blog
    /*------------------------------------------------------------------*/

    //  Blog Slider
    $(".blog-slider").royalSlider({
        loop: true,
        autoHeight: true,
        // autoScaleSlider: true,
        imageScaleMode: 'fill',
        imageAlignCenter: false,
        slidesSpacing: 0,
        arrowsNav: true,
        controlNavigation: 'none',
        keyboardNavEnabled: true,
        arrowsNavAutoHide: true,
        sliderDrag: true,
        usePreloader: true,
        imageScalePadding: 0,
        transitionType: 'fade',
        transitionSpeed: 400,
    });


	/*------------------------------------------------------------------*/
    /*   Sidebar
    /*------------------------------------------------------------------*/

    var is_sidebar_open = false;

    // Update Sidebar Height
	var _update_sidebar_height = _.throttle(function() {
		if ( viewport_width > 1280 ) {
			$('.ss-sidebar').css('height', function() {
		    	return $(document).height() - 30;
		    });
		} else {
			$('.ss-sidebar').css('height', '');
		}
	}, 300);
	$window.resize(_update_sidebar_height);
	_update_sidebar_height();
    
    $('.ss-sidebar-btn').on('click', function(e) {
    	e.preventDefault();
    	if ( is_sidebar_open ) {
			$('.ss-sidebar').removeClass('ss-open');
			is_sidebar_open = false;
    	} else {
    		$('.ss-sidebar').addClass('ss-open');
    		is_sidebar_open = true;
    	}
    });

    $('.ss-sidebar').on('click',function(e) {
    	e.stopPropagation();
    });

    $body.on('click', function() {
    	$('.ss-sidebar').removeClass('ss-open');
    	is_sidebar_open = false;
    });


	/*------------------------------------------------------------------*/
    /*   Comments
    /*------------------------------------------------------------------*/

    $('#comment').on('focus', function() {
    	$(this).css('height', '150px');
    });

    $('#comment').on('focusout', function() {
    	$(this).css('height', '');
    });


	/*------------------------------------------------------------------*/
    /*   Testimonial Slider
    /*------------------------------------------------------------------*/

    var $testimonial_slider = $('.ss-testimonial-slider-inner'),
		testimonial_slider_sly = [];

	$testimonial_slider.each( function(index) {
		var $this =  $(this);
		testimonial_slider_sly[index] = new Sly( $(this), {
			horizontal: 1,
			smart: 1,
			activateMiddle: 1,
			scrollBy: 0,
			dragHandle: 1,
			dynamicHandle: 0,
			itemNav: 'forceCentered',
			clickBar: 1,
			speed: 900,
			mouseDragging: 1,
			touchDragging: 1,
			releaseSwing:  1,
			swingSpeed: 0.1,
			elasticBounds: 0,
			easing: 'easeOutExpo',
			cycleInterval: 5000,
			pauseOnHover:  1,
		    // pagesBar: $this.siblings('.ss-twitter-roller2-nav'),
		    activatePageOn: 'click',
		    pageBuilder: function (index) {
	            return '<a href="#"></a>';
	        },
		}).init();
		var _update_testimonial_slider = _.throttle(function() {

			// Set & Update height for parent
			$this.find('.ss-testimonial-slider').css('height', function() {
				return $this.find('.ss-testimonial-slide').eq(0).height() + 'px';
			});

			// Set & Update width for item
			$this.find('.ss-testimonial-slide').css('width', function() {
				return $this.closest('.ss-testimonial-slider-inner').width() + 'px';
			});

			// Update Sly
			testimonial_slider_sly[index].reload();

		}, 100);
		$window.resize(_update_testimonial_slider);
		setTimeout(function() {
			_update_testimonial_slider();
		}, 4000);
		

		$('.ss-twitter-roller2-nav a').on('click', function(e) {
			e.preventDefault();
		});
		
	});


	/*------------------------------------------------------------------*/
    /*   Clients
    /*------------------------------------------------------------------*/

    $('.ss-client').on( 'mouseenter', function() {
    	$(this).addClass('ss-hover');
    });
    $('.ss-client').on( 'mouseleave', function() {
    	$(this).removeClass('ss-hover');
    });


});