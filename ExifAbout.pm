package ExifAbout;

use strict;
use warnings;
use Encode qw(decode);
use Gtk3;
use Exporter 'import';

our @EXPORT_OK = qw(show_about);

sub show_about {
    my ($parent) = @_;

    my $top = Gtk3::Window->new('toplevel');
    $top->set_title("About exif_edit");
    $top->set_default_size(400, 300);
    $top->set_position('center');
    $top->set_transient_for($parent);

    my $about_txt = <<'END_ABOUT';
* This program writes comments to images as an EXIF 'Comment' tag.

For more Documentation see:
https://github.com/jlseagull67/exif-edit/blob/main/exif_edit

Disclaimer:

This program is provided 'as is.' It may be freely modified or redistributed under the same terms as Perl itself.

Programmer: Jörg Albrecht

END_ABOUT

    my $vbox = Gtk3::Box->new('vertical', 5);
    $vbox->set_border_width(10);
    $top->add($vbox);

    my $scrolled_win = Gtk3::ScrolledWindow->new;
    $scrolled_win->set_policy('automatic', 'automatic');
    my $textview = Gtk3::TextView->new;
    $textview->set_editable(0);
    $textview->set_cursor_visible(0);
    $textview->set_wrap_mode('word');
    $textview->get_buffer->set_text(decode('UTF-8', $about_txt));
    $scrolled_win->add($textview);
    $vbox->pack_start($scrolled_win, 1, 1, 0);

    my $close_button = Gtk3::Button->new("Close");
    $close_button->signal_connect(clicked => sub { $top->destroy });
    $vbox->pack_start($close_button, 0, 0, 0);

    $top->show_all;
}

1;
