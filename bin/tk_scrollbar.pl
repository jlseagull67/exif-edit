        #! /usr/bin/perl5 -w

        use strict;
        use Tk;

        my $main = MainWindow->new;
        my $box = $main->Listbox(-relief => 'sunken',
                                 -width => -1, # Shrink to fit
                                 -height => 5,
                                 -setgrid => 1);
        my @items = qw(One Two Three Four Five Six Seven
                       Eight Nine Ten Eleven Twelve);
        foreach (@items) {
           $box->insert('end', $_);
        }
        my $scroll = $main->Scrollbar(-command => ['yview', $box]);
        $box->configure(-yscrollcommand => ['set', $scroll]);
        $box->pack(-side => 'left', -fill => 'both', -expand => 1);
        $scroll->pack(-side => 'right', -fill => 'y');

        MainLoop;