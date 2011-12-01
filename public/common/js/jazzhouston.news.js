/*************************
 * news js
 *
 * @author: Andrew Lienhard
 **************************/

Ext.namespace('jh.news');

jh.news = function() {

    // default refresh freq in secs
    var frequency=6;

    var NEWS_MAIN_URL=jh.util.HOST_NAME + '/articles/';

    /** show detail Url **/
    var ARTICLE_URL=jh.util.HOST_NAME + '/articles/words/';

    /** show detail Url **/
    var PREVIEW_URL=jh.util.HOST_NAME + '/articles/preview/';

    /** rotator Url **/
    var ROTATE_URL=jh.util.HOST_NAME + '/articles/rotate/';

    // display template for rotator
    var loadingTemplate = new Ext.Template('<br/><br/><img src="/images/ajax-loader.gif">');
    var rotateTemplate = new Ext.Template(
        '<div class="{cls}">',
//            '<a href="'+NEWS_MAIN_URL+'">See all headlines</a><br/><br/>',
        '<a href="'+ARTICLE_URL+'{id}">{title}</a><br/>',
        '<img src="{img}" align="left" width="125" hspace="2"> {about:ellipsis(300)}',
        '</div>'
    );


    // display template for article preview
    var previewTemplate = new Ext.Template(
        '<div class="{cls}">',
        '<b>{title}</b> -- {about:ellipsis(300)}',
        ': <a href="'+ARTICLE_URL+'{id}">read</a>',
        '</div>'
    );

    // simple Ext window for previews



    // PUBLIC
    return {


        /** loading template **/
        loader: function(divId) {
            loadingTemplate.overwrite(divId, {});
        },
        dialogWindow: null,

        createWindow: function(divId, contentEl) {
            this.dialogWindow= new Ext.Window({
                applyTo     : divId,
                layout      : 'fit',
                width       : 500,
                height      : 200,
                cls: 'panel-inside-rotate',
                pageX: 100,
                pageY: 100,
                closeAction :'hide',
                plain       : true,
                contentEl: contentEl,
                buttons: [{
                    text     : 'Submit',
                    disabled : true
                },{
                    text     : 'Close',
                    handler  : jh.util.scope(this,this.closeWindow)
                }]
            });

            this.dialogWindow.show();

            return this.dialogWindow;

        },

        closeWindow: function() {
            if (this.dialogWindow) {
                this.dialogWindow.hide();

            }
        },

        /** rotate counter **/
        counter: 0,

        // rotate articles
        rotate: function (articles, counter, divId) {
            if (counter===articles.length) {
                counter=0;
            }
            var listing = articles[counter++].content;

            rotateTemplate.overwrite(divId, {cls: 'panel-inside-rotate',
                title:  listing.title, about: listing.teaser, id: listing.content_id, img: listing.image_url});

            var func =jh.util.scope(this, function() {
                this.rotate(articles, counter, divId);
            });
            setTimeout(func, 1000*frequency);
        },

        /** starts news rotator **/
        startNewsCycle: function(divId, frequency) {

            this.frequency = frequency || this.frequency;
            this.loader(divId);

            // AJAX
            Ext.Ajax.request({
                url: ROTATE_URL,
                success: function(response) {
                    var articles =jh.util.json_eval(response).articles;
                    jh.news.rotate(articles, 0, divId);
                },
                scope: this
            });
        },

        /** article previewer **/
        previewArticle: function(articleId, windowDivId, articlePreviewDivId) {

            Ext.Ajax.request({
                url: PREVIEW_URL +articleId,
                success: function(response)
                {
                    var words =jh.util.json_eval(response).content;

                    previewTemplate.overwrite(articlePreviewDivId, {cls: 'panel-inside',
                        title:  words.title, about: words.teaser, id: words.content_id, img: words.image_url});

                    this.createWindow(windowDivId,articlePreviewDivId); // your function to create the window


                },
                scope: this
            });
        }

    };
}();


