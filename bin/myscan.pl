#!/usr/bin/perl -w
    use strict;
    use warnings;

##############################################    
# Programm zur Ansteuerung des Epson-Scanners
# Dies soll die komfortablere Alternative zu ImageScan sein.
# 
# Leider ist es nicht gelungen, alle benötigten
# commadlineParameter auf einmal an den Scanner zu
# schicken - das CommandlineInterface nimmt nur
# wenige Zeichen auf einmal entgegen.
# Deshalb muss hier 2 stufig vorgegangen werden:
# 1. Scannen mit dem CLI des Scanner 
# und 2. Bildbearbeitung mit Linux-Mitteln
#
# Umbau auf scanimage aus dem SANE-Projekt
# hier werden beliebig viele Parameter entgegen
# genommen.
# Doku unter scanimage_doc
#
##############################################
    
    
 use lib "/opt/myperl/lib";
 use lib ".";  
    
    use Tk;
    use Tk::TFrame;
    use Tk::JPEG;
    #use Tk::FileEntry;
    use mod_image;
    use Datei;
    #use myscan;

    
##############################################    
##### Global Settings / Mappings #############
##############################################
    
    my %image_type_map = (1 => 'Lineart'
                         ,2 => 'Gray'
                         ,3 => 'Color'
                         );
    my $default_image_type = 3;
    
    my %resolution_map = (1 => 100
                         ,2 => 200
                         ,3 => 300
                         );
    my $default_resolution_sel = 2;                     
                         
   # suffix pdf können wir erst in der Nachverarbeitung einsetzen, daher erstmal rausgenommen.      
    my %suffix_map     = ('PDF' => 'pdf'
                         ,'JPEG'=> 'jpeg'
                         ,'PNG' => 'png'
                         ,'TIFF'=> 'tif'
                         ,'PNM' => 'pnm' 
                         );                  
    my $default_dest_type = 'PDF';
    
    my $default_dest_sel               = 0; # Scannen (Achtung - Absturz bei Default Kopieren)
    my $default_source_sel             = 2; # Einzug
    my $default_source_sel_ds          = 0; # Einseitig
    my $default_colorresolution_sel    = 3; # bunt
    my $default_colorresolution_sel_wa = 1; # mit Weißabgleich
    my $default_printer                = 'OKI_C532@oki-c532.local';
    my $default_print_sel_ds           = 0; # Druck doppelseitig
     
##############################################    
##### MainWindow ###############
##############################################
    my $mw = Tk::MainWindow->new();
    
##############################################    
##### AllAction - Frame ###############
##############################################
    my $aaf = $mw->Frame();
    

##############################################    
##### Dest - Frame           
# Hier wird festgelegt, ob gescannt oder kopiert wird
##############################################
    my $tf1 = $aaf->TFrame(
       -label => 'Ziel',
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill   => 'x'
    );
    my $dest_sel = $default_dest_sel;

    my $rb_dest1 = $tf1->Radiobutton(
    	-text     => 'Scannen',
    	-value    => 0,
    	-variable => \$dest_sel,
    	-command  => \&dest_show_hide
    )->pack(-side => 'left', -padx => 4);
    
    my $rb_dest2 = $tf1->Radiobutton(
    	-text     => 'Kopieren',
    	-value    => 1,
    	-variable => \$dest_sel,
    	-command  => \&dest_show_hide
    )->pack(-side => 'left', -padx => 4);
    
    
    
##############################################    
##### Source - Frame           
# Hier wird die Papierquelle (Einzug oder Flachbett) festgelegt
# bei Einzug (ADF) besteht noch die Option auf Doppelseitig
##############################################
    my $tf2 = $aaf->TFrame(
       -label => 'Quelle',
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill   => 'x'
    );
    my $source_sel = $default_source_sel;
    my $source_sel_ds = $default_source_sel_ds;
    my $rb_source1 = $tf2->Radiobutton(
    	-text     => 'Vorlagenglas',
    	-value    => 1,
    	-variable => \$source_sel,
    	-command  => \&source_ds_show_hide
    )->pack(-side => 'left', -padx => 4);
    
    my $rb_source2 = $tf2->Radiobutton(
    	-text     => 'Einzug',
    	-value    => 2,
    	-variable => \$source_sel,
    	-command  => \&source_ds_show_hide
    )->pack(-side => 'left', -padx => 4);
    
    my $rb_source3 = $tf2->Checkbutton(
    	-variable => \$source_sel_ds,
    	-text => 'doppelseitig',
    	-onvalue  => 1,
    	-offvalue => 0,
    
    )->pack(-side => 'left',-padx => 4);
    
    &source_ds_show_hide;
    
##############################################    
##### Resolution - Frame ###############
##############################################
    my $showhide_frame0 = $aaf->Frame()->pack(-anchor => 'nw'
                                             ,-expand => 1
                                             ,-fill => 'x'
                                             );
    my $tf3 = $showhide_frame0->TFrame(
       -label => 'Aufloesung',
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
           );
    
    my $resolution_sel = $default_resolution_sel;
    
    my $rb_res1 = $tf3->Radiobutton(
    	-text => 'niedrig',
    	-value => 1,
    	-variable => \$resolution_sel,
    	-command => \&special_resolution_show_hide,
    )->pack(-side => 'left'
           ,-padx => 4
           );
    
    my $rb_res2 = $tf3->Radiobutton(
    	-text => 'mittel',
    	-value => 2,
    	-variable => \$resolution_sel,
    	-command => \&special_resolution_show_hide,
    )->pack(-side => 'left'
           ,-padx => 4
           );
 
    my $rb_res3 = $tf3->Radiobutton(
    	-text => 'hoch',
    	-value => 3,
    	-variable => \$resolution_sel,
    	-command => \&special_resolution_show_hide,
    )->pack(-side => 'left'
           ,-padx => 4
           );

    my $rb_res4 = $tf3->Radiobutton(
    	-text => 'spezial',
    	-value => 4,
    	-variable => \$resolution_sel,
    	-command => \&special_resolution_show_hide,
    )->pack(-side => 'left'
           ,-padx => 4
           );

##############################################    
##### Special Resolution - Frame ###############
##############################################
    # Der Showhide-Frame bleibt am festen Platz
    # unabhängig davon, ob der Inhalt gerade existiert oder nicht.
    my $showhide_frame1 = $aaf->Frame()->pack(-anchor => 'nw'
                                             ,-expand => 1
                                             ,-fill => 'x'
                                             );
    
    my $tf7 = $showhide_frame1->TFrame(
       -label => 'Spezial Aufloesungen',
    );
  
    my $spec_resolution_sel = &resolution_calc;
    
    my $sc_resolution1 = $tf7->Scale(
	-from	=> 50, -to => 1200,
	-resolution => 50,
        -length => 280,
	-orient	=> 'horizontal',
	-label	=> 'Aufloesung',
	-variable => \$spec_resolution_sel,
    )->pack(-side => 'left'
           ,-expand => 1
           ,-fill => 'x'
           ,-padx => 4
           );
    
    
##############################################    
##### ColorResolution - Frame ###############
##############################################

    my $tf4 = $aaf->TFrame(
       -label => 'Farbaufloesung',
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
           );
           
    my $colorresolution_sel = $default_colorresolution_sel;
    my $colorresolution_sel_wa = $default_colorresolution_sel_wa;
    my $rb_cres1 = $tf4->Radiobutton(
    	-text => 'S/W',
    	-value => 1,
    	-variable => \$colorresolution_sel,
    )->pack(-side => 'left', -padx => 4);
    
    my $rb_cres2 = $tf4->Radiobutton(
    	-text => 'grau',
    	-value => 2,
    	-variable => \$colorresolution_sel,
    )->pack(-side => 'left', -padx => 4);
    my $rb_cres3 = $tf4->Radiobutton(
    	-text => 'bunt',
    	-value => 3,
    	-variable => \$colorresolution_sel,
    )->pack(-side => 'left'
           ,-padx => 4
           );
    my $rb_cres4 = $tf4->Checkbutton(
    	-text => 'weissablg.',
    	-variable => \$colorresolution_sel_wa,
    	-onvalue  => 1,
    	-offvalue => 0,        	
    )->pack(-side => 'left'
           ,-padx => 4
           );
           
##############################################    
##### Threshold - Frame ###############
##############################################
    # Der Showhide-Frame bleibt am festen Platz
    # unabhängig davon, ob der Inhalt gerade existiert oder nicht.
    my $showhide_frame2 = $aaf->Frame()->pack(-anchor => 'nw'
                                             ,-expand => 1
                                             ,-fill => 'x'
                                             );


   my $tf5 = $showhide_frame2->TFrame(
       -label => 'Kontrast/Helligkeit',
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
           );
    
   my $brightness_sel=0;
   my $sc_thresh1 = $tf5->Scale(
	-from	=> -9, -to => 9,
	-orient	=> 'horizontal',
	-label	=> 'Helligkeit',
        -length => 280,
	-variable => \$brightness_sel,
   )->pack(-side => 'top', -padx => 4);

   my $contrast_sel=0;
   my $sc_thresh2 = $tf5->Scale(
	-from	=> -9, -to => 9,
	-orient	=> 'horizontal',
	-label	=> 'Kontrast',
        -length => 280,
	-variable => \$contrast_sel,
   )->pack(-side => 'top', -padx => 4);

   # zunächstmal nicht sichtbar
   $tf5->packForget;

##############################################    
##### Datei-Auswahl - Frame ###############
##############################################
   # my $dest_file_suffix = 'pdf';
   
    my $showhide_frame3 = $aaf->Frame()->pack(-anchor => 'nw'
                                             ,-expand => 1
                                             ,-fill => 'x'
                                             );

    my $dest_file='/home/joerg/_aa/perl_tk/tmp/datei';

    my $tf8 = $showhide_frame3->TFrame(
       -label => 'Speicherort'
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
           );
       # initialisieren der Auswahlbox
    my @dest_types = keys %suffix_map;
 
    my $dest_type = $default_dest_type;
    
    my $om_scan1 = $tf8->Optionmenu(-variable => \$dest_type 
                                   ,-options  => \@dest_types
                                   ,-command => \&change_dest_type
    )->pack(-side => 'right'
           ,-padx => 4
           ,-pady => 4
           );
   
    
  #  $tf8->FileEntry(-variable => \$dest_file,
  #  )->pack(-expand => 1, -fill => 'x');
    
    my $entry = $tf8->Entry(-textvariable => \$dest_file
    )->pack(-expand => 1
           ,-padx => 4
           ,-fill => 'x'
           ,-side => 'bottom'
           );

    sub change_dest_type{   
      $entry->update;
      print "in change_dest_type: - $dest_type - $suffix_map{$dest_type} \n";
    } 
            
           
##############################################    
##### Action - Frame ###############
##############################################
    my $tf9 = $aaf->TFrame(
        -label => [ -text => 'Aktion' ],
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
           );
    my $b_action1 = $tf9->Button(
    	-text => 'Scan',
    	-command => \&action_scan,
    )->pack(-side => 'left'
           ,-padx => 4);
    my $b_action2 = $tf9->Button(
    	-text => 'Kopie',
    	-command => \&action_print,
    )->pack(-side => 'left'
           ,-padx => 4);
    
    ################################
    ## Anzahl der Kopien
    my $copy_count = 1;
    my $b_action_cc_down = $tf9->Button(
    	-text => '-',
    	-command => \&print_count_down,
    )->pack(-side => 'left'
           ,-padx => 4);
    my $e_action_cc = $tf9->Entry(-textvariable => \$copy_count
                                 ,-width => 3
    )->pack(-side => 'left'
           ,-padx => 0);
    my $b_action_cc_up = $tf9->Button(
    	-text => '+',
    	-command => \&print_count_up,
    )->pack(-side => 'left'
           ,-padx => 0);       
           
    sub print_count_up{
      $copy_count++ if $copy_count lt 99;
    }
    sub print_count_down{
      $copy_count-- if $copy_count gt 1;
    }
           
    ## ENDE Anzahl der Kopien
    ################################
    
    my $b_action3 = $tf9->Button(
    	-text => 'Vorschau',
    	-command => \&action_preview,
    )->pack(-side => 'left'
           ,-padx => 4);

    my $b_action4 = $tf9->Button(
    	-text => 'Ausschnitt',
    )->pack(-side => 'left'
           ,-padx => 4);

    my $print_sel_ds = $default_print_sel_ds;
    my $rb_action1 = $tf9->Checkbutton(
    	-text => 'Druck doppels.',
    	-variable => \$print_sel_ds,
    	-onvalue  => 1,
    	-offvalue => 0,        	
    )->pack(-side => 'bottom'
           ,-pady => 4
           );       
           
    $tf9->pack(-expand => 1
          # ,-padx => 4
           ,-fill => 'x'
          # ,-side => 'bottom'
           );
           
           
##############################################    
##### Scan - Frame ###############
##############################################
   
    my $tf6 = $aaf->Frame(
    -relief => 'groove',
    -borderwidth => 2,
    )->pack(-anchor => 'nw'
           ,-expand => 1
           ,-fill => 'x'
    );
    
 #   my $b_scan1 = $tf6->Button(
 #   	-text => 'START',
 #   	-command => \&start,
 #   )->pack(-side => 'left'
 #          ,-padx => 4
 #          ,-pady => 4
 #          );
           
    # bind für den Startpunkt - obere linke Ecke
    
    
 
   # initialisieren der Auswahlbox
  # my @dest_types = keys %suffix_map;
 
  # my $dest_type = $dest_types[0];
#    
#    my $om_scan1 = $tf6->Optionmenu(-variable => \$dest_type 
#                                   ,-options  => \@dest_types
#                                   ,-command => \&change_dest_type
#    )->pack(-side => 'top'
#           ,-padx => 4
#           ,-pady => 4
#           );
#           
#    sub change_dest_type{   
#      $entry->update;
#      print "gotcha \n";
#    }
      
       
##############################################    
##### Preview - Frame ###############
##############################################

    my $pv = $mw->Frame(
    -relief => 'groove',
    -borderwidth => 2,
    );
    
    my $max_pv_width = 670;
    my $max_pv_hight = 920;
    
    my $can1 = $pv->Canvas(-width  => $max_pv_width
                          ,-height => $max_pv_hight
                          ,-background => "white"
    )->pack(-fill => 'both'
           ,-expand => 1
           );
    
      
    $pv->grid(-row => 0
             ,-column => 0
             );
    
    my $lastx=1;
    my $lasty=1;
    
#     # Vorschaubild vor dem Rahmen definieren, damit es hinter dem Rahmen liegt
#     my $file   = "tmp/~test.jpg";
#     my $img = $mw->Photo( -file => $file);
#     $can1->createImage( 0, 0, -image => $img, -anchor => 'nw' );
      
    
    
    # einen Rahmen erzeugen - Ort und Größe verändern wir später
    my $myline = $can1->createLine(
        0,0,0,0,0,0,0,0,0,0,
        -fill => 'black',
        -width => 1,
        -tags => ['line'],
    );
 
    # bind für den Startpunkt - obere linke Ecke
    $pv->bind($can1, '<1>', sub{ startpunkt($myline); });
    
    # bind für das Aufziehen des Rechtecks
    $pv->bind($can1, '<B1-Motion>', sub{ moveit($myline); });
    
    # initialisieren der Koordinaten
    my ( $x1, $y1 ) = (0,0);
    my ( $x2, $y2 ) = (0,0);
  
 sub startpunkt {
   my $object = shift(@_);
   my ( $x, $y ) = ( $Tk::event->x, $Tk::event->y );
    #print "x1: $x   y1:$y \n";
   $x1 = $x;
   $y1 = $y;
 
 }
    
 sub moveit {
    my $object = shift(@_);
    my ( $x, $y ) = ( $Tk::event->x, $Tk::event->y );
    
    if ($x >= $max_pv_width) {
      $x2 = $max_pv_width - 1 ;
    } 
    elsif ($x <= 0) {
      $x2 = 1;
    } 
    else {
      $x2 = $x;
    };
    if ($y >= $max_pv_hight) {
      $y2 = $max_pv_hight-1;
    }
    elsif ($y <= 0) {
      $y2 = 1;
    }
    else {
      $y2 = $y;
    };
    #print "x1: $x1   y1:$y1   x2: $x2   y2:$y2 \n";
 
    
    # aufziehen des Rechtecks
    $can1->coords($object,  $x1,$y1,$x1,$y2,$x2,$y2,$x2,$y1,$x1,$y1);
}

    $pv->pack(-side => 'left');
    $aaf->pack(-anchor => 'ne');
    &dest_show_hide;
    $mw->MainLoop();

    
 

#########################################################
# Ab hier werden die "Programmteile" abgelegt, die
# über das TK-Frontend (bis hier) angesprochen werden.
#
# Der Teil ab hier sollte in ein Modul ausgegliedert werden,
# was aber eine saubere Variablen- und Objektkapselung 
# voraussetzt
#########################################################


    
##############################################
##############################################
### action - Subs
##############################################
sub action_preview {
    
    my $image_type=$image_type_map{$colorresolution_sel};
    my $resolution=&resolution_calc;
    
    
#     my $brightness=sign($brightness_sel).'0.0'.abs($brightness_sel);
#     my $contrast=sign($contrast_sel).'0.0'.abs($contrast_sel);
#     
    
    my $param="";
    $param .= "--format=jpeg ";
    $param .= "--mode ".$image_type." ";
    $param .= "--resolution 80 ";    
   
    #print "$param\n";
    
    # Arbeitsverzeichnis für das Vorschaubild
    my ($orgpath,$workpath,$filebase,$suffix) = &BaueArbeitsverzeichnis($dest_file);
    
    
    `scanimage -d epsonds $param  > $workpath$filebase.jpg`;
    
    # Weißabgleich über die (Roh-)Ergebnisse
    if ($colorresolution_sel_wa == 1) {
      &i_normalize_pattern("$workpath$filebase.jpg");
    }
    
    my $file   = "$workpath$filebase.jpg";
    my $img = $mw->Photo( -file => $file);
    $can1->createImage( 0, 0, -image => $img, -anchor => 'nw' );
    
    # Arbeitsverzeichnis löschen
    &LoescheArbeitsverzeichnis($dest_file);
    
}

#########################################################
# ab hier wird mit den gewählten Einstellungen in eine
# Datei gescannt
#########################################################
sub action_scan {
    
    my $image_type=$image_type_map{$colorresolution_sel};
    my $resolution=&resolution_calc;
    
    # hier mappen wir den dest_type auf den File-Suffix
    my $dest_file_suffix = $suffix_map{$dest_type};
    
    # für die Bearbeitung benutzen wir dieses Suffix nur z.Teil
    my $work_suffix = '';
    
    
    # Arbeitsverzeichnis anlegen - wird nicht immer benötigt, aber macht das
    # Programm übersichtlicher, wenn es immer da ist.
    # Das hier ermittelte Suffix wird - wenn es denn da ist, nicht weiter verwendet.
    # stattdessen ist das $dest_file_suffix maßgeblich.
    my ($orgpath,$workpath,$filebase,$suffix) = &BaueArbeitsverzeichnis($dest_file);
    
    #die "$orgpath,$workpath,$filebase,$suffix\n";
    
    # wenn pdf gewählt ist, müssen wir png (Bitmap) scannen und im Nachgang in pdf umwandeln
    # => immer in den workpath
    my $path = '';
    if ($dest_file_suffix eq 'pdf') {
    
      # Bei pdf-Ziel, scannen wir als Bitmap (png) / (jpeg macht es kleiner)
      $work_suffix = 'jpeg';
      $path = $workpath;
    
    }
    else {
      $work_suffix = $dest_file_suffix;
      # alles <> pdf kommt direkt in den orgpath
      $path = $orgpath;
    }
    
    
   
    my $param=" ";
    $param .= "--mode ".$image_type." ";
    $param .= "--format=$work_suffix ";
    $param .= "--resolution $resolution ";
    
    # ADF
    if ($source_sel eq 2) {
      $param .= "--source Automatic ";
      $param .= "--adf-skew=yes ";
      # Den Batch-Mode schalten wir dann auch ein
      $param .= "--batch='".$path.$filebase."%d.".$work_suffix."' ";
      # Wenn wir mit 100 starten, dann sind wir sicher, dass bis 999 alle Dateien richtig sortiert werden.
      $param .= "--batch-start=100 ";
      # Die Seitenlänge stellen wir auf A4
      $param .= "-y 297 ";
      if ($source_sel_ds eq 1) {
        $param .= "--adf-mode Duplex ";
      } # Default ist Simplex
    }
    # Flachbett
    elsif ($source_sel eq 1) {
      $param .= "--source Flatbed ";
    }
      
    # Die Unterscheidung zwischen ADF und Flatbed ist auch die Entscheidung für oder gegen Batch-Modus
    # Im Flachbett-Modus kommen die Daten auf std_out an und werden in die Datei umgeleitet.
    if ($source_sel ne 2) {
      $param .= " > $path$filebase.$work_suffix"; 
    }
    
    print ">> scanimage $param\n";
    `scanimage  $param `;
 
    # Weißabgleich über die (Roh-)Ergebnisse
    if ($colorresolution_sel_wa == 1) {
      &i_normalize_pattern("$path$filebase*");
    }
      
 
    # Nach dem Scan png in pdf wandeln, und von workpath nach orgpath bringen
    if ($dest_file_suffix eq 'pdf') {
      print "$path$filebase* -> $orgpath$filebase.$dest_file_suffix\n";
      &i_join_pdf("$path$filebase*", "$orgpath$filebase.$dest_file_suffix");
    }
    
    
    # Arbeitsverzeichnis löschen
    &LoescheArbeitsverzeichnis($dest_file);
}




#########################################################
# Bei der Kopie wird ein spezieller Dateiname vergeben, die Auflösung auf die Druckerauflösung gesetzt
# der 'normale' Scanvorgang gestartet und das Ergebnis an den Drucker gesendet
#########################################################
sub action_print {
  
 # das Ubuntu-Wiki schlägt noch folgenden convert für gescannte Dateien vor:
 #   convert ROHDATEI.png \
 #   -normalize -gamma 0.8,0.8,0.8 \
 #   -colorspace HSL \
 #   -channel saturation -fx 'min(1.0,max(0.0,3*u.g-1))' \
 #   -colorspace RGB \
 #   +dither -posterize 3 \
 #   BEARBEITET.png
    
 # Druckeroption doppelseitig drucken:
 # lpr -o sides=two-sided-long-edge filename  
 # lpr -o sides=one-sided filename (default)

  #### ab hier geht's los
  
  # Farbaufloesung einbinden
  my $image_type=$image_type_map{$colorresolution_sel};
  
  # Arbeitsverzeichnis definieren
  my $print_dir = './.print';
   
  # erst löschen, wenn es noch da sein sollte
  if (-e $print_dir) {
    `rm -r $print_dir`;
    print "Lösche Arbeitsverzeichnis ($print_dir)\n";
  }
  
    
  # Jetzt anlegen
  print "Arbeitsverzeichnis anlegen ($print_dir)\n";
  if (! mkdir $print_dir) {
    die "Fehler beim Anlegen des Druckverzeichnisses ($!)";
  }
 
  # Scannen als Bitmap
  my $work_suffix = 'pnm';
  my $filebase = 'print_tmp';
  my $param  = " ";
     $param .= "--mode ".$image_type." ";
     $param .= "--format=$work_suffix ";
     $param .= "--resolution 300 ";
    
    # ADF
    if ($source_sel eq 2) {
      $param .= "--source Automatic ";
      $param .= "--adf-skew=yes ";
      # Den Batch-Mode schalten wir dann auch ein
      $param .= "--batch='".$print_dir.'/'.$filebase."%d.".$work_suffix."' ";
      # Wenn wir mit 100 starten, dann sind wir sicher, dass bis 999 alle Dateien richtig sortiert werden.
      $param .= "--batch-start=100 ";
      # Die Seitenlänge stellen wir auf A4
      $param .= "-y 297 ";
      if ($source_sel_ds eq 1) {
        $param .= "--adf-mode Duplex ";
      } # Default ist Simplex
    }
    # Flachbett
    elsif ($source_sel eq 1) {
      $param .= "--source Flatbed ";
      $param .= '> '.$print_dir.'/'.$filebase."100.".$work_suffix;
    }
 
 #die "scanimage   -d epsonds  $param";
    # Einscannen der Vorlage
     `scanimage   -d epsonds  $param`;
     my $retcode = &iscan_fehlercheck($?);
     
    # Ausdruck nur, wenn der Scan in Ordnung war (### Die Meldung müssen wir noch einfangen ###)
    if ($retcode eq 0) {
      # Einzelscans zu einem PDF zusammenfassen (auch wenn es nur eine Seite ist)
      &i_join_pdf('./.print/print_tmp*','./.print/print_out.pdf');
       # Wenn gewünscht, vor dem Ausdruck noch einen Weißabgleich
      if ($colorresolution_sel_wa == 1) {
        &i_normalize_pdf('./.print/print_out.pdf', './.print/print_out.pdf');
      }
      
      ## option zum doppelseitigem Druck
      my $print_option = ' ';
      if ($print_sel_ds eq 1) {
        $print_option .= '-o sides=two-sided-long-edge ';
      }
      if ($image_type ne 'Color') {
        $print_option .= '-o mode=Gray ';
      }
      
      Trace("lpr -P $default_printer $print_option  ./.print/print_out.pdf");
      
      # Ausgabe auf den Drucker - bei mir heißt der: OKI_C532@oki-c532.local
      # grau/bunt oder einseitig/doppelseitig geben wir als optionen mit
      `lpr -P $default_printer $print_option  ./.print/print_out.pdf`;
      # Hilfsdatei löschen
      `rm -r ./.print`;
    }
      
}

sub iscan_fehlercheck {
  my $retcode = shift(@_);
  my $meldung = shift(@_);
  if ($retcode) {
    print " habe Fehler beim Scannen bemerkt ($meldung)\n";
  }
  return $retcode;
}


sub resolution_calc {

    my $res=$resolution_map{$resolution_sel};
    if ($resolution_sel eq 4) {
      $res = $spec_resolution_sel;
    }
    #print "$res \n";    
    return $res;
}

sub dest_show_hide {
    
    ## Auswahl: Kopieren
    if ($dest_sel eq 1) {
       $tf3->packForget;       #Aufloesungen Frame
       $tf7->packForget;       #Spezialauflösungen Frame
       $tf8->packForget;       #Speicherort Frame
       $b_action1->packForget; #Start Button
       $b_action3->packForget; #Vorschau Button
       $b_action4->packForget; #Ausschnitt Button
       $b_action2->pack(-side => 'left', -padx => 4);        #Kopie Button
       $b_action_cc_down->pack(-side => 'left', -padx => 4); #Kopie Anzahl senken Button
       $e_action_cc->pack(-side => 'left', -padx => 4);      #Kopie Anzahl
       $b_action_cc_up->pack(-side => 'left', -padx => 4);   #Kopie Anzahl erhöhen Button
       $mw->bind('<Key-Return>', sub{ &action_print; });
       $rb_action1->pack(-side => 'bottom', -pady => 4); # Druck doppelseitig
    }
    else {
    ## Auswahl: Scannen
       $tf3->pack(-expand => 1
                 ,-side => 'left'
                 ,-fill => 'x');
       $tf8->pack(-expand => 1     
                 ,-side => 'left'
                 ,-fill => 'x');
       $b_action2->packForget; #Kopie Button
       $b_action_cc_down->packForget;
       $b_action_cc_up->packForget;
       $e_action_cc->packForget;
       $rb_action1->packForget; # Druck doppelseitig
       $b_action1->pack(-side => 'left', -padx => 4);
       $b_action3->pack(-side => 'left', -padx => 4);
       $b_action4->pack(-side => 'left', -padx => 4);
       $mw->bind('<Key-Return>', sub{ &action_scan; });
       $mw->update;
       &special_resolution_show_hide();
    }
}

sub source_ds_show_hide {
     
    if ($source_sel eq 1) {
       $rb_source3->packForget; # doppelseitig-Checkbox
    }
    else {
       $rb_source3->pack(-side => 'left', -padx => 4);
       $mw->update;
    }
}

sub special_resolution_show_hide {
     
    if ($resolution_sel ne 4) {
       $tf7->packForget;
    }
    else {
       $tf7->pack(-expand => 1
                 ,-side => 'left'
                 ,-fill => 'x');
       $mw->update;
    }
}




sub sign {
  my $zahl = shift(@_);
  if ($zahl lt 0) {return '-'}
  else {return ''}
}
    
   
