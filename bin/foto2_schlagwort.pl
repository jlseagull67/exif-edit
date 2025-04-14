#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use Tk::JPEG;
use Tk::Photo;

# Directory containing images
my $image_dir = '/home/joerg/Bilder/Juli';

# Thumbnail size
my $thumb_width = 100;
my $thumb_height = 100;

# Create main window
my $mw = MainWindow->new;
$mw->title("Photo Thumbnails");

# Frame to hold the thumbnails
my $frame = $mw->Frame()->pack(-side => 'top', -fill => 'both', -expand => 1);

# Read image files from the directory
opendir(my $dh, $image_dir) or die "Cannot open directory $image_dir: $!";
my @images = grep { /\.(jpg|jpeg|png|gif)$/i } readdir($dh);
closedir($dh);

# Load and display thumbnails
foreach my $image (@images) {
    my $image_path = "$image_dir/$image";

    # Create a Tk::Photo object
    my $photo = $mw->Photo(-file => $image_path);

    # Scale the image to thumbnail size
    my $thumb = $photo->copy();
    $thumb->subsample($photo->width/$thumb_width, $photo->height/$thumb_height);

    # Create a Label to hold the thumbnail
    my $label = $frame->Label(-image => $thumb)->pack(-side => 'left', -padx => 10, -pady => 10);
}

MainLoop;
