/*************************
 * forums js
 *
 * @author: Andrew Lienhard
 **************************/

var jh = {};
jh.forums = (function() {

  var scoreURL = "/forums/vote";

  /**
   * Hides a message row
   * @param mid
   */
  function hide_post(mid) {
	var row=$("#row_"+mid);
	row.addClass("blockedMessage");
	var alertDiv = $("#rowAlert_"+mid);
	alertDiv.show();
	var messageDiv = $("#message_"+mid);
	messageDiv.hide();
	var authorDiv = $("#messageAuthor_"+mid);
	authorDiv.hide();
  }

  /**
   * Shows a message row
   * @param mid
   */
  function show_post(mid) {
	var row=$("#row_"+mid);
	row.addClass("blockedMessage");
	var alertDiv = $("#rowAlert_"+mid);
	alertDiv.hide();
	var messageDiv = $("#message_"+mid);
	messageDiv.show();
	var authorDiv = $("#messageAuthor_"+mid);
	authorDiv.show();
  }


  // PUBLIC
  return {

	acceptTerms: function() {

	  return confirm("By clicking OK, you (The User) are agreeing to the Jazzhouston.com posting policy. " +
			  "This policy strictly prohibits posts that are inflammatory, " +
			  "rude, hostile, cruel, unlawful, unsuitable for public viewing, and/or deemed offensive in any " +
			  "manner we, the site editors of Jazzhouston.com, define. Posts in violation of this policy are subject to removal. " +
			  "Repeat offenders may have their accounts closed. " +
			  "All decisions on this issue are " +
			  "final and completely at the discretion of the Jazzhouston.com editors. " +
			  "Furthermore, The User is solely liable for their " +
			  "submissions. The User agrees to indemnify and hold harmless Jazzhouston.com, its subsidiaries, affiliates, contractors, " +
			  "agents and/or employees against any liability, be it civil, criminal, or quasi-criminal, resulting from the use of this website. " +
			  "If you do not accept these terms, do not post here.");

	},

	/**
	 * Rates posts and takes action on row as needed.
	 * @param mid  messageId
	 * @param mode vote UP or DOWN
	 * @param lflag logged in or not boolean
	 */
	rate_post: function(mid, mode, lflag) {

	  if (!lflag) {
		alert("You must be logged in to vote.");
	  }

	  $.ajax({
		type: "GET",
		url: scoreURL + "/" + mid + "?mode=" + mode,
		contentType: "application/json; charset=utf-8",
		async: true,
		dataType: "json",
		success: function(response) {
		  if (response.success==0) {
			alert(response.alert);
			return;
		  }

		  var hide = response.hide;
		  var open = response.reopen;

		  var score_box = $("#score_" + mid);
		  score_box.text("Thanks for your vote! ");
		  if (hide) {
			hide_post(mid);
		  }  else if (open) {
			show_post(mid);
		  }

		}
	  });
	}


  };

})();


