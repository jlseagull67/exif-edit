#!/usr/bin/perl -w

# exiftool -overwrite_original -Comment='Schmetterling; Großes Ochsenauge' $file1


use strict;
use Tk;
use Tk::PNG;
use Tk::JPEG;

use utf8;

my $main = new MainWindow;


my $file1 = "20240708_114200.JPG";
my $comment1 = `exiftool -Comment $file1`;
$comment1 =~ s/Comment                         : //;
$comment1 =~ s/Ã/ß/;
chomp $comment1;


my $image = $main->Photo(-file => $file1);
$main->Button(-text => 'Exit'
             ,-width => 300
             ,-height => 300
             ,-command => sub { exit }
             ,-image => $image)->pack;
$main->Label(-text => $file1
             )->pack;

#$main->Label(-text => $comment1         )->pack;
$main->Entry(-text => $comment1
               ,-width => 50
             )->pack;


$main->Button(-text => 'Rewrite',
	          -command => sub{
		my $entry_value = $main.Entry->get();
		print "$entry_value\n";
		`exiftool -overwrite_original -Comment="Schmetterling; Großes Ochsenauge2" $file1`;
	},
              )->pack;
MainLoop;


