#!/usr/bin/perl -w
use Tk;
use strict;
my $main = new MainWindow;
my $button = $main->Button();
$button -> configure(-text => 'Press me!');
$button -> pack;
MainLoop;
