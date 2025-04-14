       #! /usr/bin/perl5 -w

        use strict;
        use Tk;

        my $main = MainWindow->new;
        $main->Label(-text => 'Print file')->pack;
        my $font = $main->Entry(-width => 10);
        $font->pack;
        my $filename = $main->Entry(-width => 10);
        $filename->pack;
        $main->Button(-text => 'Fax',
                      -command => sub{do_fax($filename, $font)}
                      )->pack;
        $main->Button(-text => 'Print',
                      -command => sub{do_print($filename, $font)}
                      )->pack;
        MainLoop;

        sub do_fax {
            my ($file, $font) = @_;
            my $file_val = $file->get;
            my $font_val = $font->get;
            print "Now faxing $file_val in $font_val\n";
        }

        sub do_print {
            my ($file, $font) = @_;
            my $file_val = $file->get;
            my $font_val = $font->get;
            print "Sending file $file_val to printer in $font_val\n";
        }