#!/usr/bin/perl -w
#########################################################################################
#
# Programm:	Projekt TestWorks
#
# Paket: tk_testworks.pl
#
# Frontend zur Verwaltung der Entwicklungs-/Testumgebung des DWH
#
#
# Programmierung: Jörg Albrecht
# Datum:	11.04.2003
#
# Historie:	11.04.2003	Jörg Albrecht	Erstellung
#
#########################################################################################

use strict 'vars';
use diagnostics;

## Parameter holen ##
our $paramUserPrefix = 'x';
our $paramDBSchema = 'CWHADM';
our @paramAllChecked = qw[0 0 0 0 0 0 0 0];
our $paramTabAnzahl = 0;

use Tk;
use Tk::Table;
## Defintion des Hauptfensters
my $main = MainWindow->new;


################################ Frame Definition ####################################
## MenuFrame anlegen
my $MenuFrame = $main->Frame;
$MenuFrame->pack(-anchor => 'w');
	
## Headframe anlegen
my $HeadFrame = $main->Frame;
$HeadFrame->pack(-anchor => 'w');

## mainframe anlegen
my $MainFrame = $main->Frame;
$MainFrame->pack(-anchor => 'w');

	## Treeframe anlegen
	my $TreeFrame = $MainFrame->Frame(-height => 10);
	$TreeFrame->pack(-side => 'left');

	## Detailframe anlegen
	my $DetailFrame = $MainFrame->Frame(-height => 10);
	$DetailFrame->pack;
	

## statusframe anlegen
my $StatusFrame = $main->Frame;
$StatusFrame->pack(-anchor => 'w', -fill=>'x');
################################ Ende Frame Definition ####################################
################################ Menü Definition       ####################################
my $Menu_file = $MenuFrame->Menubutton(-text => 'File...');
$Menu_file->command(-label => 'Choose Environment...',
	     -command => [\&DBSchema, $paramDBSchema]);
$Menu_file->command(-label => 'User prefix...',
	     -command => [\&UserPrefix, $paramUserPrefix]);
$Menu_file->separator;
$Menu_file->command(-label => 'Exit',
	     -command => sub {$main->destroy;});
$Menu_file->pack(-side => 'left');

my $Menu_edit = $MenuFrame->Menubutton(-text => 'Edit...');
$Menu_edit->command(-label => 'View Script',
	     	-command => \&skriptWindow );
$Menu_edit->command(-label => 'Execute Script',
	     	-command => sub {});	     	
$Menu_edit->pack(-side => 'left');

my $Menu_help = $MenuFrame->Menubutton(-text => 'Help');
$Menu_help->command(-label => 'About...',
		-command => \&AboutWindow );
$Menu_help->pack(-side => 'right');
################################ Ende Menü Definition  ####################################
################################ Head Definition       ####################################
my $Header = $HeadFrame->Label(-text => '##', -font => 'Arial');
#$Header->pack(-side => "top",  -padx => 1, -pady => 1);
################################ Ende Head Definition  ####################################
################################ Tree Definition       ####################################
use Tk::Tree;
my $TreeList = $TreeFrame->Scrolled(Tree,
				 -scrollbars => 'osow',
				 -relief => 'sunken',
                                 -width => 40,
                                 -height => 10);
#$TreeList->pack;
################################ Ende Tree Definition  ####################################
################################ Detail Definition     ####################################
#our $DetailZeilen = 0;
our @Zelleninhalt = ();
our $DetailTable = '';
##DetailHeader
$paramTabAnzahl = &DetailTable;



################################ Ende Detail Definition ###################################
################################ Status Definition      ###################################
my $status = $StatusFrame->Label(-relief => "sunken", -bd => 1, -anchor => 'w');
$status->pack(-side => "bottom", -fill=> 'x', -padx => 2, -pady => 1);
################################ Ende Status Definition ###################################
################################ Detail und Tree befüllen #################################
#&ParseDetail;
################################ Ende Detail und Tree befüllen ############################

MainLoop;
##Ende des Hauptprogramms


#########################################################################################
## Erzeugung HeaderZeile im Detailframe
##
## In-Parameter : --
## Out-Parameter: --
#########################################################################################
sub DetailTable
{
	# lese all_columns und gebe die Tabellennamen zurück
	my @TabNames = &leseAllTables();
	my $TabZahl = @TabNames;
	
	$TabZahl++;
	$DetailTable = $DetailFrame->Table(
				-columns => 7,
				-rows => $TabZahl,
				-fixedrows => 1,
				-scrollbars => 'se');
	
## Header befüllen
	my @Head = ();
	$Head[0] = $DetailTable->Button(-text => "Number", -state =>'disabled', -width=>8);
	$DetailTable->put(0, 1, $Head[0]);
	$Head[1] = $DetailTable->Button(-text => "Name", -state =>'disabled', -width=>40);
	$DetailTable->put(0, 2, $Head[1]);
	$Head[2] = $DetailTable->Button(-text => "View", -width=>8, -command => [\&checkAll, 3]);
	$DetailTable->put(0, 3, $Head[2]);
	$Head[3] = $DetailTable->Button(-text => "Table", -width=>8, -command => [\&checkAll, 4]);
	$DetailTable->put(0, 4, $Head[3]);
	$Head[4] = $DetailTable->Button(-text => "Empty", -width=>8, -command => [\&checkAll, 5]);
	$DetailTable->put(0, 5, $Head[4]);
	$Head[5] = $DetailTable->Button(-text => "where...", -state =>'disabled', -width=>8);
	$DetailTable->put(0, 6, $Head[5]);
	$Head[6] = $DetailTable->Button(-text => "use Constraints", -width=>12, -command => [\&checkAll, 7]);
	$DetailTable->put(0, 7, $Head[6]);

## Tabelle befüllen
	my $ZeilNr = 0;
	my @Zeile = ();
	my $TabName = '';
	foreach $TabName (@TabNames)
	{
		$ZeilNr++;
		$Zeile[0] = $DetailTable->Label(-text => "$ZeilNr", -width=>10);
		$DetailTable->put($ZeilNr, 1, $Zeile[0]);
		
		$Zeile[1] = $DetailTable->Label(-text => "$TabName", -width=>30, anchor =>'w');
		$DetailTable->put($ZeilNr, 2, $Zeile[1]);
		
		$Zeile[2] = $DetailTable->Checkbutton( -width=>8);
		$DetailTable->put($ZeilNr, 3, $Zeile[2]);
		
		$Zeile[3] = $DetailTable->Checkbutton( -width=>8);
		$DetailTable->put($ZeilNr, 4, $Zeile[3]);
	
		$Zeile[4] = $DetailTable->Checkbutton( -width=>7);
		$DetailTable->put($ZeilNr, 5, $Zeile[4]);
	
		$Zeile[5] = $DetailTable->Button(-text =>'...', -width=>7, 
					-command => [\&WhereKlausel , $ZeilNr]);
		$DetailTable->put($ZeilNr, 6, $Zeile[5]);
		
		##$Zeile[6] ist der Text der where-clause
		$Zeile[7] = $DetailTable->Checkbutton( -width=>8);
		$DetailTable->put($ZeilNr, 7, $Zeile[7]);
	
	        $Zelleninhalt[$ZeilNr] = [@Zeile];
        
	}
	#$DetailTable->see('5','5');

## Tabelle Packen
	$DetailTable->pack(-expand => 0, -fill => 'both');	
	
	return $ZeilNr;
}


#########################################################################################
## Anzeige des About-Fensters
##
## In-Parameter : --
## Out-Parameter: --
#########################################################################################
sub AboutWindow
{
	use Tk::Animation;
	
	my $AboutWindow = $main->Toplevel (-title          => 'Über VTS - Ini-Editor');
	$AboutWindow->focus;
		
	$AboutWindow->Label(-text => 'TestWorks')->pack(-ipadx => 100,
									-ipady => 8);
	$AboutWindow->Label(-text => 'Author:')->pack;
	$AboutWindow->Label(-text => 'Jörg Albrecht')->pack;
	$AboutWindow->Label(-text => '11.04.2003')->pack;
	$AboutWindow->Button(-text => 'OK',
				'-command'     => sub { $AboutWindow->destroy })->pack;
}


#########################################################################################
## Editfenster für Where-Klausel
##
## In-Parameter : Zeilennummer
## Out-Parameter: --
#########################################################################################
sub WhereKlausel
{
	my $Zeile = shift(@_);
	my $WhereWindow = $main->Toplevel (-title => 'TestWorks - where-Editor');
	
	my $Text = $WhereWindow->Text(-height => 10, -cursor => 'top_left_arrow')->pack;
	$Text->insert('end',$Zelleninhalt[$Zeile][6]);
	$Text->focus;
	$WhereWindow->Button(-text => 'OK',
				'-command'     => sub { 
					my $Line = 1;
					my $Col = 0;
					$Zelleninhalt[$Zeile][6] = $Text->get($Line.'.'.$Col, 'end');
					chomp($Zelleninhalt[$Zeile][6]);
					$WhereWindow->destroy })->pack;
}

#########################################################################################
## Editfenster für User Präfix
##
## In-Parameter : paramUserPrefix
## Out-Parameter: --
#########################################################################################
sub UserPrefix
{
	my $UserPrefixWindow = $main->Toplevel (-title => 'TestWorks - Set User Prefix');
	
	my $Text = $UserPrefixWindow->Entry(-width => 40);
	$Text -> insert(0,$paramUserPrefix);
	$Text ->pack;
	$Text->focus;
	
	$UserPrefixWindow->Button(-text => 'OK',
				'-command'     => sub { $paramUserPrefix = $Text->get;
					$UserPrefixWindow->destroy })->pack;
}

#########################################################################################
## Auswahlfenster für DB-Schema
##
## In-Parameter : paramDBSchema
## Out-Parameter: --
#########################################################################################
sub DBSchema
{
	my $DBSchemaWindow = $main->Toplevel (-title => 'TestWorks - Set DB Scheme');
	
	my $Text = $DBSchemaWindow->Entry(-width => 40);
	$Text -> insert(0,$paramDBSchema);
	$Text ->pack;
	$Text->focus;
	
	$DBSchemaWindow->Button(-text => 'OK',
				'-command'     => sub { $paramDBSchema = $Text->get;
					$DBSchemaWindow->destroy })->pack;
}

#########################################################################################
## Checkboxen setzen für View
##
## In-Parameter : Spalte, die 'gechecked' werden soll, Checkstatus bisher
## Out-Parameter: Checkstatus nachher
#########################################################################################
sub checkAll
{
	my $Checkcol = shift(@_);
	my $i = 0;
	my $Widget = '';
	SWITCH:
	{
		if ($paramAllChecked[$Checkcol] eq 0) 
		{ 
			$paramAllChecked[$Checkcol] = 1;
			for $i (1..$paramTabAnzahl)
			{
				$Widget = $DetailTable->get($i,$Checkcol);
				$Widget->select;
			}
			last SWITCH; 
		}
		if ($paramAllChecked[$Checkcol] eq 1) 
		{ 	
			$paramAllChecked[$Checkcol] = -1;
			for $i (1..$paramTabAnzahl)
			{
				$Widget = $DetailTable->get($i,$Checkcol);
				$Widget->deselect;
			}
			last SWITCH; 
		}
		if ($paramAllChecked[$Checkcol] eq -1) 
		{
			$paramAllChecked[$Checkcol] = 1;
			for $i (1..$paramTabAnzahl)
			{
				$Widget = $DetailTable->get($i,$Checkcol);
				$Widget->select;
			}
			last SWITCH; 
		}
	}
	
}

#########################################################################################
## Aus den Widget-Ergebnissen das CreateSkript bauen
##
## In-Parameter : --
## Out-Parameter: Skripttext
#########################################################################################
sub createSkript
{
	my $Skript = '';
	my $Widget = '';
	my %Widget = ();
	my $Tabname = '';
	
	my $i = 0;
	for $i (1..$paramTabAnzahl)
	{
		##View selected?
		$Widget = $DetailTable->get($i,3);
		%Widget = %$Widget;
		if ($Widget{Value})
		{
			# Tabname
			$Widget = $DetailTable->get($i,2);
			$Tabname = $Widget->cget('-text');		
			$Skript .= "CREATE OR REPLACE VIEW $Tabname\n";
			$Skript .= "AS SELECT * FROM $paramDBSchema\n";
			if (defined $Zelleninhalt[$i][6])
			{
				$Skript .= "$Zelleninhalt[$i][6]"; #where-Klausel
			}
			$Skript .= ";\n";
		}
	}
	#print $Skript,"\n";
	return $Skript;
}

#########################################################################################
## Editfenster für CreateSkript
##
## In-Parameter : Skript
## Out-Parameter: --
#########################################################################################
sub skriptWindow
{
	my $Skript = &createSkript;
	my $SkriptWindow = $main->Toplevel (-title => 'TestWorks - Skript-Editor');
	
	my $Text = $SkriptWindow->Scrolled(Text,-height => 10, -cursor => 'top_left_arrow')->pack;
	$Text->insert('end',$Skript);
	$Text->focus;
	$SkriptWindow->Button(-text => 'OK',
				'-command'     => sub { 
					my $Line = 1;
					my $Col = 0;
					$Skript = $Text->get($Line.'.'.$Col, 'end');
					chomp($Skript);
					$SkriptWindow->destroy })->pack;
}

#########################################################################################
## Alle zur Debatte stehenden Tabellennamen lesen
##
## In-Parameter : --
## Out-Parameter: --
#########################################################################################
sub leseAllTables
{
	return qw[DT_CUSTOMER DT_AUFTRAG DT_ICHHIER DT_DUAUCH WD_TIME WD_SCHLUMPF e r t z u i o p ü a s d f g h j k l ö ä];
}



#########################################################################################
## Parameter vorbelegen
##
## In-Parameter : zu trimmender String
## Out-Parameter: getrimmter String
#########################################################################################
sub getParameter
{
	
}


#########################################################################################
## entfernt auch Zeilenumbruchzeichen, die hier nicht sein sollten
## In-Parameter : zu trimmender String
##		
## Out-Parameter: getrimmter String
#########################################################################################
sub Doublechomp
{
	my $String = shift(@_);
	if ($String)
	{
		chomp($String);
		my $Cr = $/;  #Zeilenumbruchzeichen merken
		$/=chr(13);
		chomp($String);
		$/ = $Cr;  #Zeilenumbruchzeichen zurücksetzen
	}
	return $String;
}