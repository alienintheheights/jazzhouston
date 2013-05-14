jazzhouston
===========

rails app for jazzhouston web site, http://jazzhouston.com. 

Currently using Rails 3.0.20 and Ruby 1.8.7 (hosting service doesn't have Ruby 1.9 yet and I don't want to set it up locally on their servers).

File uploader for articles is via the Paperclip gem, v.2.7, consistent with the older version of ImageMagick in use on their servers.

File uploader for users is running an ancient gem called File_Column. Will migrate to Paperclip soon. File_Column is no longer supported.

In May 2013, I refactored the site to use Twitter Bootstrap. There's still some ExtJS code in use that will get thrown out soon.



