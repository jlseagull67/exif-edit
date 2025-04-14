       #! /usr/bin/perl5 -w

        use strict;
        use Tk;

        # Take top, the bottom -> now implicit top is in the middle
        my $main = MainWindow->new;
        $main->Label(-text => 'At the top (default)')->pack;
        $main->Label(-text => 'At the bottom')->pack(-side => 'bottom');
        $main->Label(-text => 'The middle remains')->pack;

        # Since left and right are taken, bottom will not work...
        my $top1 = $main->Toplevel;
        $top1->Label(-text => 'Left')->pack(-side => 'left');
        $top1->Label(-text => 'Right')->pack(-side => 'right');
        $top1->Label(-text => '?Bottom?')->pack(-side => 'bottom');

        # But when you use frames, things work quite alright
        my $top2 = $main->Toplevel;
        my $frame = $top2->Frame;
        $frame->pack;
        $frame->Label(-text => 'Left2')->pack(-side => 'left');
        $frame->Label(-text => 'Right2')->pack(-side => 'right');
        $top2->Label(-text => 'Bottom2')->pack(-side => 'bottom');

        MainLoop;