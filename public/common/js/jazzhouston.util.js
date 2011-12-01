/*************************
 *  common js utils
 *
 * @author: Andrew Lienhard
 **************************/
Ext.namespace('jh.util');

jh.util = function() {

    // private variables

    // private functions
    function isString(obj) {
        return ( typeof obj == "string" || obj instanceof String);
    }

    // public space
    return {

        // auto-detect to make AJAX security happy
        HOST_NAME: window.location.protocol + "//" + window.location.host,

        // public methods

        /** eval wrapper **/
        json_eval: function(response, options) {
            var jsonData = eval('('+ response.responseText +')');
            return jsonData.data[0];
        },

        /** scoping function useful for callbacks **/
        scope: function(thisObject, func) {
            var args = [];
            for (var i = 2; i < arguments.length; ++i ) {
                args.push(arguments[i]);
            }

            var f = (isString(func) ? thisObject[func] : func) || function(){};
            return function(){
                var copyArgs = args.concat([]);
                for (var j = 0; j < arguments.length; ++j ) {
                    copyArgs.push(arguments[j]);
                }

                return f.apply(thisObject, copyArgs);
            };
        },

        /** simple pop-up window **/
        popup: function(url, height /* optional */, width /* optional */) {
            height=height||200;
            width=width||200;

            newwindow=window.open(url,'name','height='+height+',width='+width);
            if (window.focus) {newwindow.focus()}
            return false;

        }


    };
}(); // end of app



