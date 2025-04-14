    #!/usr/bin/perl -w
    use Tk;
    use strict;
    my $main = new MainWindow;
    
    use Tk::Tree;
    my $hl = $main->ScrlTree();
    $hl -> add("Level1", 
    	-text => 'Blah');
    $hl -> add("Level1.Level2", 
    	-text => 'Blub');
    $hl -> add("Level1.Level2.Level3", 
    	-text => 'Blub2');
    $hl -> pack;
   
   
    MainLoop;
