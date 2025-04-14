use strict 'vars';
use diagnostics;

use Tk;
## Defintion des Hauptfensters
my $main = MainWindow->new;


################################ Frame Definition ####################################
## MenuFrame anlegen
my $MenuFrame = $main->Frame;
$MenuFrame->pack(-anchor => 'w');
	
my $Framebox = $MenuFrame->Listbox(-height => 10);
$Framebox->pack;
my $Listbox = $Framebox->Listbox->pack;
my $DetailScroll = $Framebox->Scrollbar(-command => ['yview', $Framebox]);
        $Framebox->configure(-yscrollcommand => ['set', $DetailScroll]);
        
        $DetailScroll->pack(-side => 'right', -fill => 'y');


my $i = 0;

my $knopf = '';
for $i (0..30)
{
	$knopf = $Listbox->Label(-text => "Table", -width=>10);
	
	$knopf->pack
}
$Listbox->packPropagate(0);
MainLoop;