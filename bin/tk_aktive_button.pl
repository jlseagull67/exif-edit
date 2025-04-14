
    #!/usr/local/bin/perl -w
   
    use Tk;
   
    $main = MainWindow->new;
   
    $QPBFile  = "demos/images/QuitPB.xpm";
    $QPBaFile = "demos/images/QuitPBa.xpm";
   
    $QuitPB  = $main->Pixmap('-file' => Tk->findINC("$QPBFile"));
    $QuitPBa = $main->Pixmap('-file' => Tk->findINC("$QPBaFile"));
   
    my $but  = $main->Button('-image'       => $QuitPB,
                             '-activeimage' => $QuitPBa,
                             '-command'     => sub { $main->destroy }
                            ) -> pack;
   
    MainLoop;
   
    __END__
   