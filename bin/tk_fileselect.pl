use Tk;
use Tk::FileSelect;


my $top = new MainWindow( -title => "File Select" );
main( $top );
MainLoop();

sub main
{
    my( $top ) = @_;
    my $start_dir = 'h:';
 $FSref = $top->FileSelect(-directory => $start_dir);
 #              $top            - a window reference, e.g. MainWindow->new
 #              $start_dir      - the starting point for the FileSelect
 $file = $FSref->Show;
 #              Executes the fileselector until either a filename is
 #              accepted or the user hits Cancel. Returns the filename
 #              or the empty string, respectively, and unmaps the
 #              FileSelect.
# $FSref->configure(option => value[, ...])
 #              Please see the Populate subroutine as the configuration
 #              list changes rapidly.
}