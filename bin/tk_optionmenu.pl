   use Tk;
    my $mw = MainWindow->new();

    my $var;
    my $opt = $mw->Optionmenu(
                -options => [qw(jan feb mar apr)],
                -command => sub { print "got: ", shift, "\n" },
                -variable => \$var,
                )->pack;

    $opt->addOptions([may=>5],[jun=>6],[jul=>7],[aug=>8]);

    $mw->Label(-textvariable=>\$var, -relief=>'groove')->pack;
    $mw->Button(-text=>'Exit', -command=>sub{$mw->destroy})->pack;

    MainLoop;