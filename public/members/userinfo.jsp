<%@ page import="java.util.*, com.jazzhouston.user.*, com.jazzhouston.venue.*, com.jazzhouston.event.*, com.jazzhouston.*" %>
<jsp:useBean id="agent" scope="page" class="com.jazzhouston.user.UserManager" />
<jsp:setProperty name="agent" property="*" />
<jsp:useBean id="artists" scope="page" class="com.jazzhouston.user.MusicianManager" />
<jsp:setProperty name="artists" property="*" />

<%@ include file="/common/curtains_top.jsp" %>
<%

    User theyBe = (User)agent.getItem();
    if (theyBe==null ) {
%>
<jsp:forward page="/members/login.jsp" />
<%
    }
    Enumeration axes=null;
    Musician gigger=null;
    if (theyBe.getLocalPlayerFlag()==1)
    {
        gigger = (Musician)artists.getItem();
        if (gigger!=null)
        {
            Vector instVector = gigger.getInstrumentVector();

            if (instVector!=null)
                axes = instVector.elements();
        }
    }

    int memberHere=0;
    if (youBe!=null && youBe.getUserID()==theyBe.getUserID())
        memberHere=1;

%>

<link rel="stylesheet" href="/common/new/ajax.css" type="text/css"></link>
<link rel="stylesheet" href="/common/new/slidingdoors.css" type="text/css"></link>
<script src="/common/scripts/prototype.js" type="text/javascript"></script>
<script src="/common/scripts/effects.js" type="text/javascript"></script>
<script src="/common/scripts/dragdrop.js" type="text/javascript"></script>
<script src="/common/scripts/controls.js" type="text/javascript"></script>
<script  type="text/javascript">
    function afterSelect(text, li)
    {
        window.location="/venues/about.jsp?key="+li.id;
    }

    var currentID="bio";
    function switchTo(id)
    {
        if (currentID==id)
            return;
        var selectedObj=document.getElementById(id);
        selectedObj.style.display='';
        if (currentID!="")
        {
            var currentObj=document.getElementById(currentID);
            currentObj.style.display='none';
        }
        currentID=id;
    }
</script>
<script type="text/javascript">
    <!--

    if ( ( typeof( NN_reloadPage ) ).toLowerCase() != 'undefined' ) { NN_reloadPage( true ); }
    if ( ( typeof( opacity_init  ) ).toLowerCase() != 'undefined' ) { opacity_init(); }
    if ( ( typeof( set_min_width ) ).toLowerCase() != 'undefined' ) { set_min_width( 'pageWrapper' , 500 ); }

    //-->
</script>
<title>JazzHouston | Member Center | Member Profile </title>

<%@ include file="/common/curtains_untilstage.jsp" %>

<div id="Stage">
<div class="inside">
><a href="/home.jsp">Home</a>
><b>Community Member Profile</b>

<div class="hspacer"></div>
<div class="Header">JazzHouston.com Community Profile</div>
<div class="hspacer"></div>
<div id="leadContent">
<div id="header">
    <ul>
        <li><a href="javascript:void(0)" onClick='switchTo("bio")'>profile</a></li>
        <li><a href="javascript:void(0)" onClick='switchTo("details")'>details</a></li>        
        <li><a href="javascript:void(0)" onClick='switchTo("contacts")'>contact</a></li>       
    </ul>
</div>


<div class="profileBox" id="bio" style="display:block;">
    <br>
    <p class="titleText"  align="left">
        <% if (theyBe.getFullName()!=null && theyBe.getFullName().length()>0) { %>
        <%=theyBe.getFullName()%>  <br>
        <% } %>
        <%  if (theyBe.getLocalPlayerFlag()==1) { %>
         <span class="smallText"><b>Instruments: </b>
        <%
            if (axes!=null)
            {
                int c=0;
                while (axes.hasMoreElements() )
                {
                    Instrument plays = (Instrument)axes.nextElement();
                    if (c!=0)
                    {
                        out.println(", ");
                    }

        %>
        <a href="/artists/byinst.jsp?searchByInst=<%=plays.getInstrumentID()%>"><%=plays.getName()%></a>
	     <%
                     c++;
                 }
             }
         %>
        </span>
    </p>
    <%  } %>
    <% if (theyBe.getImageUrl()!=null && theyBe.getImageUrl().length()>0) { %>
    <img src="<%=theyBe.getImageUrl()%>" alt="<%=theyBe.getFullName()%>" height="150" align="left" hspace="5" valign="top">
    <% }   %>

    <p class="mediumTextTimes" align="left">
        <% if (theyBe.getAboutMe()!=null && theyBe.getAboutMe().length()>0) { %>
        <%=theyBe.getAboutMeRE()%> <br><br>
        <% } else { %>
        Sorry, no profile available.<br><br>
        <% } %>
    </p>
    <br><br><br><br>
</div>

<div class="profileBox" id="details" style="display:none;">
    <br>
    <p class="mediumTextTimes" align="left">
        <% if (theyBe.getUserName()!=null && theyBe.getUserName().length()>0) { %>

        <br> <span style="float:left; width:30%"><B>User Name</b></span>
        <span style="float:left"><%=theyBe.getUserName()%></span><br> <br>

        <%
            }
            if (theyBe.getFullName()!=null && theyBe.getFullName().length()>0) {
        %>

        <span style="float:left; width:30%"><B>Better Known As...</b></span>
        <span style="float:left"><%=theyBe.getFullName()%></span>  <br> <br>

        <%
            }
            if (theyBe.getUrl()!=null && theyBe.getUrl().length()>0) {
        %>
        <span style="float:left; width:30%"><b>Personal Homepage</b></span>
        <span style="float:left"><a href="<%=theyBe.getUrl()%>"><%=theyBe.getUrl()%></a></span>  <br> <br>

        <%
            }
            if (theyBe.getLocation()!=null && theyBe.getLocation().length()>0) {
        %>
        <span style="float:left; width:30%"><b>Location</b></span>
        <span style="float:left"><%=theyBe.getLocation()%></span> <br> <br>
        <%
            }
            if (theyBe.getOccupation()!=null && theyBe.getOccupation().length()>0) {
        %>
        <span style="float:left; width:30%"><b>Occupation</b></span>
        <span style="float:left"><%=theyBe.getOccupation()%></span>   <br> <br>
        <%
            }

        %>
    </p>
</div>

<div class="profileBox" id="contacts" style="display:none;">
    <br>     <br>
    <p class="mediumTextTimes" align="left">
        <%
            if (theyBe.getEmail().length()>0) {
        %>
        <span style="float:left; width:25%"><b>Email</b></span>
        <span style="float:left"><a href="mailto:<%=theyBe.getEmail()%>"><%=theyBe.getEmail()%></a></span>   <br> <br>
        <%
            }
        %>
        <%

         if (theyBe.getLocalPlayerFlag()==1 && null!=gigger) {
            if (gigger.getCellPhone()!=null && gigger.getCellPhone().length()>0)
            {
        %>
        <br>
        <span style="float:left; width:25%"><B>Cell Phone</b></span>
        <span style="float:left"><%=gigger.getCellPhone()%></span>  <br> <br>

        <%
            }
            if (gigger.getHomePhone()!=null && gigger.getHomePhone().length()>0)
            {
        %>
        <span style="float:left; width:25%"><B>Home Phone</b></span>
        <span style="float:left"><%=gigger.getHomePhone()%></span>  <br> <br>
        <%
            }
            if (gigger.getBusinessPhone()!=null && gigger.getBusinessPhone().length()>0)
            {
        %>
        <span style="float:left; width:25%"><B>Business Phone</b></span>
        <span style="float:left"><%=gigger.getBusinessPhone()%></span>  <br> <br>
        <%
            }
	 }

        %>
    </p>
</div>
</div>
<div class="hspacer"></div>
<%
    if (memberHere==1) {
%>

<p class="mediumText">
    <a href="/members/update.jsp?key=<%=youBe.getUserID()%>">Update your Profile!</a>
</p>

<% } %>

</div>
</div>

<%@ include file="/common/curtains_afterstage.jsp" %>
