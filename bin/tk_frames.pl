      #!/usr/bin/perl -w
    use Tk;
    use strict;
    my $main = new MainWindow;

##Frame 1 (oben)
    my $frame = $main->Frame;
    $frame->pack;
    $frame->Label(-text => 'Left2')->pack(-side => 'left');
    $frame->Label(-text => 'Right2')->pack(-side => 'right');
    
## Frame 2 (unten)
    my $frame2 = $main->Frame;
    $frame2->pack;
    $frame2->Label(-text => 'Bottom2')->pack(-side => 'bottom');
    MainLoop;
