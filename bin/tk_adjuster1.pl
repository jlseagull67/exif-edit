use Tk;
  use Tk::Adjuster;

  my $f = MainWindow->new;
  my $lst1 = $f->Listbox();
  my $adj1 = $f->Adjuster();
  my $lst2 = $f->Listbox();

  my $side = 'left';
  $lst1->pack(-side => $side, -fill => 'both', -expand => 1);
  $adj1->packAfter($lst1, -side => $side);
  $lst2->pack(-side => $side, -fill => 'both', -expand => 1);
  MainLoop;