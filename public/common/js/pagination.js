(function($) {

  $.fn.scrollPagination = function(options) {

	var settings = {
	  page     : 1, // The number of posts per scroll to be loaded
	  error   : 'No More Posts!', // When the user reaches the end this is the message that is
	  // displayed. You can change this if you want.
	  delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
	  // This is mainly for usability concerns. You can alter this as you see fit
	  scroll  : true // The main bit, if set to false posts will not load as the user scrolls.
	  // but will still load if the user clicks.
	};

	// Extend the options so they work with the plugin
	if(options) {
	  $.extend(settings, options);
	}

	// For each so that we keep chainability.
	return this.each(function() {

	  // Some variables
	  $this = $(this);
	  var $settings = settings;
	  var page = $settings.page;
	  var jqmEvent = $settings.jqmEvent;
	  var busy = false; // Checks if the scroll action is happening
	  // so we don't run it multiple times

	  // Custom messages based on settings
	  var $initmessage = ($settings.scroll) ? 'Scroll for more or click here' : 'Click for more';

	  // Append custom messages and extra UI
	  $this.append('<div class="message_well_loading"></div><div class="loading-bar">'+$initmessage+'</div>');

	  function getData() {
		alert("dropping a new post " + '/forums/messages/'+options.thread_id+'.json#scroll-load=true');
		jqmEvent.preventDefault();

		$.getJSON('/forums/messages/'+options.thread_id+'.json',{page: ++page}).done(function (serverResponse) {

		  //setup an output variable to buffer the output
		  var output = [];
		  alert("receiving data");

		  // Change loading bar content (it may have been altered)
		  $this.find('.loading-bar').html($initmessage);

		  // If there is no data returned, there are no more posts to be shown. Show error
		  if(!serverResponse) {
			$this.find('.loading-bar').html($settings.error);
		  }
		  else {

			// bump the page number up
			page = $settings.page++;
			// No longer busy!
			busy = false;

			//iterate through the results, assuming the JSON returned is an array of objects
			for (var i = 0, len = serverResponse.length; i < len; i++) {

			  var post = serverResponse[i].post;

			  $( "#message_well" ).append(
					  $( "#messageWellTmpl" ).render( post )
			  );

			}

			//now append all the output at once (this saves us CPU cycles over appending each item separately)
			//$('[data-role="content]').children('ul').children('li').eq(0).html(output.join(''));

		  }
		}).fail(function( jqxhr, textStatus, error ) {
				  var err = textStatus + ', ' + error;
				  alert( "Request Failed: " + err);
				});
	  }


	  getData(); // Run function initially

	  // If scrolling is enabled
	  if ($settings.scroll) {
		// .. and the user is scrolling
		$(window).scroll(function() {
		  // var pBottom = $(window).height() + $(window).scrollTop() >= $(document).height();

		    var lessThan = $(document).height() - $(window).height() - 200;

			if ($(window).scrollTop() > lessThan && !busy ){

				// Now we are working, so busy is true
				busy = true;

				// Tell the user we're loading posts
				$this.find('.loading-bar').html('Loading Posts');

				// Run the function to fetch the data inside a delay
				// This is useful if you have content in a footer you
				// want the user to see.
				setTimeout(function() {

				  getData();

				}, $settings.delay);


			}

		});
	  }


	  // Also content can be loaded by clicking the loading bar/
	  $this.find('.loading-bar').click(function() {

		if (!busy) {
		  busy = true;
		  getData();
		}

	  });

	});
  }

})(jQuery);
