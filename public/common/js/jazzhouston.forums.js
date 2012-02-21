/*************************
 * forums js
 *
 * @author: Andrew Lienhard
 **************************/

Ext.namespace('jh.forums');

jh.forums = function() {

    // default refresh freq in secs
    var frequency=6;

    var FORUM_MAIN_URL=jh.util.HOST_NAME + '/forums/';
    var MESSAGE_URL=jh.util.HOST_NAME + '/forums/message';

    // display template for rotator
    var rotateTemplate = new Ext.Template(
        '<div class="{cls}">',
        '<a href="'+FORUM_MAIN_URL+'">See all headlines</a><br/><br/>',
        '<a href="'+MESSAGE_URL+'{id}">{title}</a> {about:ellipsis(300)}',
        '</div>'
    );


    // display template for article preview
    var previewTemplate = new Ext.Template(
        '<div class="{cls}">',
        '<b>{title}</b> -- {about:ellipsis(300)}',
        ': <a href="'+MESSAGE_URL+'{id}">read</a>',
        '</div>'
    );

    // simple Ext window for previews


    // PUBLIC
    return {


        SCORE_URL:"/forums/vote",

        /** rotate counter **/
        counter: 0,


        validatePost: function() {

            if (document.forms[0].message_message_text.value=="") {
                alert("This post is blank. Please try again. ");
                return false;
            }


            return jh.forums.acceptTerms();

        },

        validateThread: function() {
            if (document.forms[0].title.value=="") {
                alert("You must enter a title!");
                return false;
            }

            if (!Ext.get("message_message_text").getValue()) {
                alert("This post is blank. Please try again. ");
                return false;
            }


            return jh.forums.acceptTerms();

        },

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
         * Hides a message row
         * @param mid
         */
        hide_post: function(mid) {
            var row=document.getElementById("row_"+mid);
            row.className = "blockedMessage";
            var alertDiv = document.getElementById("rowAlert_"+mid);
            alertDiv.style.display="block";
            var messageDiv = document.getElementById("message_"+mid);
            messageDiv.style.display="none";
            var authorDiv = document.getElementById("messageAuthor_"+mid);
            authorDiv.style.display="none";
        },

        /**
         * Shows a message row
         * @param mid
         */
        show_post: function(mid) {
            var row=document.getElementById("row_"+mid);
            row.className = "messageRow";
            var alertDiv = document.getElementById("rowAlert_"+mid);
            alertDiv.style.display="none";
            var messageDiv = document.getElementById("message_"+mid);
            messageDiv.style.display="block";
            var authorDiv = document.getElementById("messageAuthor_"+mid);
            authorDiv.style.display="block";
        },

        /**
         * Rates posts and takes action on row as needed.
         * @param mid
         * @param mode UP or DOWN
         */
        rate_post: function(mid, mode, lflag) {

            if (lflag==false) {
                Ext.Msg.alert("Alert","You must be logged in to vote.");
            }
            // AJAX
            Ext.Ajax.request({
                url: jh.forums.SCORE_URL+"/"+mid+"?mode="+mode,
                success: function(response) {
                    var jsonData = eval('('+ response.responseText +')');
                    var new_score= jsonData["score"];
                    var success_flag=jsonData["success"];
                    if (success_flag && success_flag==1) {
                        var hide = (jsonData["hide"]==1)? true:false;
                        var open = (jsonData["reopen"]==1)? true:false;

                        var score_box = document.getElementById("score_"+mid);
                        score_box.innerHTML=(new_score>0)?"rating: +"+new_score:"rating: "+new_score;
                        if (hide) {
                            hide_post(mid);
                        }  else if (open) {
                            show_post(mid);
                        }
                    } else {
                        Ext.Msg.alert("Alert",jsonData["alert"]);
                    }
                },
                scope: this
            });
        }



    };
}();


