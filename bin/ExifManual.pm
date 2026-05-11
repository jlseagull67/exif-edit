package ExifManual;

use strict;
use warnings;
use Encode qw(decode);
use Gtk3;
use Exporter 'import';

our @EXPORT_OK = qw(show_manual);

sub show_manual {
    my ($parent) = @_;

    my $top = Gtk3::Window->new('toplevel');
    $top->set_title("Manual");
    $top->set_default_size(400, 400);
    $top->set_position('center');
    $top->set_transient_for($parent);

    my $manual_txt = <<'END_MANUAL';
This program writes comments to images as an EXIF 'Comment' tag whenever a text field is exited.

* Clicking (with any mouse button) on the filename inserts the text 'todel' into the comment field.

* Left-clicking on a thumbnail opens the image in the Chromium browser.

* Right-clicking on a thumbnail opens the image in GIMP.

* The menu contains the 'Reload' option, which does exactly that.

* The 'To Del' option moves all images to a subdirectory named 'todel' (which is created if it doesn't already exist) and then reloads the thumbnails.

* Under 'Settings > Tag Selector' (Ctrl+T) you can configure which EXIF tags are displayed in the panel and set general options such as mouse button actions.

END_MANUAL

    my $vbox = Gtk3::Box->new('vertical', 5);
    $vbox->set_border_width(10);
    $top->add($vbox);

    my $scrolled_win = Gtk3::ScrolledWindow->new;
    $scrolled_win->set_policy('automatic', 'automatic');
    my $textview = Gtk3::TextView->new;
    $textview->set_editable(0);
    $textview->set_cursor_visible(0);
    $textview->set_wrap_mode('word');
    $textview->get_buffer->set_text(decode('UTF-8', $manual_txt));
    $scrolled_win->add($textview);
    $vbox->pack_start($scrolled_win, 1, 1, 0);

    my $close_button = Gtk3::Button->new("Close");
    $close_button->signal_connect(clicked => sub { $top->destroy });
    $vbox->pack_start($close_button, 0, 0, 0);

    $top->show_all;
}

1;
