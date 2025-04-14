

    use strict;
    use Tk ();
    use Tk::TList;
    my $mw = Tk::MainWindow->new();
    my $image = $mw->Getimage('folder');
    my $tlist = $mw->TList(-orient => 'vertical');
    for my $text ( qw/one two three four five six seven eight nine/ ) {
        $tlist->insert('end',
                 -itemtype=>'imagetext', -image=>$image, -text=>$text);
    }
    $tlist->pack(-expand=>'yes', -fill=>'both');
    Tk::MainLoop;
