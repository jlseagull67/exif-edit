use Tk;
use Tk::Animation;
## Defintion des Hauptfensters
my $AboutWindow = MainWindow->new;


my @images = ();
	
	
	my $AboutFrame1 = $AboutWindow->Frame->pack(-side => 'left');
	my $AboutFrame2 = $AboutWindow->Frame->pack(-side => 'right');
	
  	my $img = $AboutWindow->Animation('-format' => 'gif', -file => 'logo.gif');
	$img->add_frames(@images);
 	 $img->start_animation("20");
 	$img->pack(propagate Animation); 
 	$AboutFrame2->Label(-text => 'Author:')->pack;
	
	$AboutFrame1->Label(-text => 'VTS - Ini-Editor 1.0')->pack(-ipadx => 100,
									-ipady => 8);
	$AboutFrame1->Label(-text => 'Author:')->pack;
	$AboutFrame1->Label(-text => 'Jörg Albrecht')->pack;
	$AboutFrame1->Label(-text => '06.04.2003')->pack;
	$AboutFrame1->Button(-text => 'OK',
				'-command'     => sub { $AboutWindow->destroy })->pack;
MainLoop;