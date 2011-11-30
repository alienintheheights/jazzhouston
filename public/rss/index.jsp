<%@ include file="/common/curtains_top.jsp" %>
<%@ page import="java.util.*,com.jazzhouston.forum.*, com.jazzhouston.*, com.jazzhouston.user.*" %>
<jsp:useBean id="boards" scope="page" class="com.jazzhouston.forum.ForumManager" />
<jsp:setProperty name="boards" property="*" />
<%
    /***************************
     * Get the Boards List
     ******************************/

// Try to get a cached version first! :)
    String clearOk = request.getParameter("update");

    if ("true".equals(clearOk)) boards.flushCache();
// self-caching list

// meta data object

    Enumeration theData=null;
    try {
        boards.setStatus(2);
        theData=boards.getItemList();
    } catch (Exception e) {
        out.println("OOPS!! " + e);
        out.println(boards.getDBS() );
    }

%>
<title>JazzHouston | RSS</title>
<%@ include file="/common/curtains_untilstage.jsp" %>

    <div id="Stage">
    <div class="inside">
        ><a href="/home.jsp">Home</a>
            >RSS
         <br><br>
        <div class="Header">JazzHouston RSS Feeds!</div>
                <p class="smallText">
                    The following jazzhouston.com content is available for external syndication
                    via RSS feeds.
                </p>
                 <p class="smallText">
                <a href="/events/rss.jsp">Today's Shows</a> <br>
                (URL: http://www.jazzhouston.com/events/rss.jsp)<br>
<a href="http://fusion.google.com/add?feedurl=http%3A//www.jazzhouston.com/events/rss.jsp"><img src="http://buttons.googlesyndication.com/fusion/add.gif" width="104" height="17" border="0" alt="Add to Google"></a> (adds the "today's show" feed to your Google home page!)
            </p>
                <p class="smallText">
                    <a href="/news/news_rss.jsp">Current Headlines</a> <br>
                    (URL: http://www.jazzhouston.com/news/news_rss.jsp)<br>
<a href="http://fusion.google.com/add?feedurl=http%3A//www.jazzhouston.com/news/news_rss.jsp"><img src="http://buttons.googlesyndication.com/fusion/add.gif" width="104" height="17" border="0" alt="Add to Google"></a> (adds the current news feed to your Google home page!)
                </p>
                More coming soon!
                <div class="Header">What is RSS?</div>
                 <p class="smallText">
                    Nerd-Speak: "RSS is a simple XML-based system that allows users to subscribe to their favorite websites.
                    Using RSS, webmasters can put their content into a standardized format, which can be viewed and
                    organized through RSS-aware software or automatically conveyed as new content on another website."
                </p>
                <p class="smallText">
                    <a href="http://en.wikipedia.org/wiki/RSS_(file_format)">WikiPedia on RSS</a>
                </p>
                 <p class="smallText">
                This allows other web sites to include our content on their pages.
                For example, portals like my.yahoo.com or <a href="http://www.pageflakes.com">Page Flakes</a>
                let you include outside feeds on your custom homepages.

                </p>
                <br>Note: The "Today's Shows" box and the "News and Reviews" boxes on the home page are getting
                their content from  our RSS feed (via AJAX).

    </div>
</div>

<%@ include file="/common/curtains_afterstage.jsp" %>
