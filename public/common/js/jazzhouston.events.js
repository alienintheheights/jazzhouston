/*************************
 * event rotator
 *
 * @author: Andrew Lienhard
 **************************/

Ext.namespace('jh.events');

jh.events = function() {

    // refresh freq in secs
    var frequency=5;

    // display tempalte
    var loadingTemplate = new Ext.Template('<br/><br/><img src="/images/ajax-loader.gif">');
    var rotateTemplate = new Ext.Template(
        '<div class="{cls}">',
        '<a href="/events/{todayStr}">See all shows for today</a><br/><br/>',
        '<a href="/events/details/{id}">{title}</a> {about:ellipsis(280)}',
        /* ' ({time})',  */
        '</div>'
    );

    return {

        /** rotate counter **/
        counter: 0,


        // URLs
        /** show detail Url **/
        SHOW_URL:jh.util.HOST_NAME + '/events/details/',

        /** rotator Url **/
        ROTATE_URL:jh.util.HOST_NAME + '/events/rotate/',

        /** loading template **/
        loader: function(divId) {
            loadingTemplate.overwrite(divId, {});
        },

        /** rotate shows **/
        rotate: function (shows, counter, divId) {

            // roll-over
            if (counter===shows.length) {
                counter=0;
            }
            // get Events object
            var listing = shows[counter++].event;

            var todayIs = new Date();
            var month = todayIs.getMonth() + 1;
            var todayStr = todayIs.getFullYear() +'/'+ month +'/'+ todayIs.getDate();

            // write object to template
            rotateTemplate.overwrite(divId, {cls: 'panel-inside-rotate',
                todayStr: todayStr, title:  listing.performer, about: listing.about, id: listing.event_id, time: listing.show_time});


            // func obj
            var func =jh.util.scope(this, function() {
                this.rotate(shows, counter, divId);
            });

            // loop it
            setTimeout(func, 1000*frequency);
        },


        /** starts news rotator **/
        startEventsCycle: function(divId, frequency) {

            this.frequency = frequency || this.frequency;

            jh.events.loader(divId);

            // AJAX
            Ext.Ajax.request({
                url: jh.events.ROTATE_URL,
                success: function(response) {
                    var shows =jh.util.json_eval(response).events;
                    jh.events.rotate(shows, 0, divId);
                },
                scope: this
            });
        },

        /** date toolbar **/
        dateToolbar: function(divId){

            var dateMenu = new Ext.menu.DateMenu({
                handler : function(datepicker, date){
                    window.location=jh.util.HOST_NAME + '/events/'+date.format('Y')+'/'+date.format('m')+'/'+date.format('d');

                }
            });

            var tb = new Ext.Toolbar({
                items: [{
                    text:'Select Date',
                    menu: dateMenu
                }]
            });
            tb.render(divId);

            function clickHandler(item, e) {
                alert('Clicked on the menu item: ' + item.text);
            }


        }
    };
}();





