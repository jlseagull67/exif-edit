#!/usr/bin/perl -w
use strict;
use warnings;
use Tk;
use Tk::Pane;
use Tk::Photo;
use Tk::JPEG;
use Image::Magick;

## Codebase by chatgpt:
#write a program in Tk-Perl under linux to show thumbnails of fotos without using Image::Magick


# Create main window
my $mw = MainWindow->new;
$mw->title("Photo Thumbnails");

# Directory containing images
my $image_dir = '/home/joerg/Bilder/Juli';

# Frame for thumbnails
my $thumb_frame = $mw->Scrolled('Frame', -scrollbars => 'e')->pack(-expand => 1, -fill => 'both');

# Get image files from directory
opendir(my $dir, $image_dir) or die "Cannot open directory: $!";
my @images = grep { /\.(jpg|jpeg|png|gif)$/i } readdir($dir);
closedir($dir);

print "@images\n";

# Function to create thumbnail
sub create_thumbnail {
    my ($image_path, $thumb_size) = @_;
    my $image = Image::Magick->new;
    $image->Read($image_path);
    $image->Resize(geometry => $thumb_size);
    my $thumb = $image->ImageToBlob;
    return $thumb;
}

# Create and display thumbnails
foreach my $image (@images) {
    my $image_path = "$image_dir/$image";
    my $thumb_data = create_thumbnail($image_path, '100x100');

    # Create a Tk Photo object
    my $photo = $thumb_frame->Photo(-data => $thumb_data);

    # Create a label to display the thumbnail
    my $label = $thumb_frame->Label(-image => $photo)->pack(-side => 'top', -padx => 10, -pady => 10);

    # Bind click event to open full-size image
    $label->bind('<Button-1>' => sub {
        my $full_image = $mw->Toplevel;
        $full_image->title($image);
        my $full_photo = $full_image->Photo(-file => $image_path);
        $full_image->Label(-image => $full_photo)->pack;
    });
}

# Run the Tk main loop
MainLoop;
