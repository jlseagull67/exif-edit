Disclaimer:

This program is provided “as is.” It may be freely modified or redistributed under the same terms as Perl itself.

Prerequisits: 

Perl
Gtk3
ExifTool

Functions:

This program writes comments to images as an EXIF “Comment” tag whenever a text field is exited.

* Clicking (with any mouse button) on the filename inserts the text “todel” into the comment field.

* Left-clicking on a thumbnail opens the image in the Chromium browser.

* Right-clicking on a thumbnail opens the image in GIMP.

* The menu contains the “Reload” option, which does exactly that.

* The “To Del” option moves all images to a subdirectory named ‘todel’ (which is created if it doesn't already exist) and then reloads the thumbnails.
