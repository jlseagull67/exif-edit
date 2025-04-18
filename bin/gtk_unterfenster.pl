#!/usr/bin/perl
use strict;
use warnings;
use Gtk3 -init;
use Glib 'TRUE', 'FALSE';

# Hauptfenster erstellen
my $window = Gtk3::Window->new('toplevel');
$window->set_title("Hauptfenster");
$window->set_default_size(300, 200);
$window->signal_connect( destroy => sub { Gtk3->main_quit });

# VBox für Menü und Inhalt
my $vbox = Gtk3::Box->new('vertical', 0);
$window->add($vbox);

# Menüleiste erstellen
my $menubar = Gtk3::MenuBar->new;
my $datei_menu = Gtk3::Menu->new;

my $datei = Gtk3::MenuItem->new("Datei");
$datei->set_submenu($datei_menu);

my $textfenster_item = Gtk3::MenuItem->new("Textfenster öffnen");
$textfenster_item->signal_connect(activate => \&open_text_window);

my $beenden_item = Gtk3::MenuItem->new("Beenden");
$beenden_item->signal_connect(activate => sub { Gtk3->main_quit });

$datei_menu->append($textfenster_item);
$datei_menu->append($beenden_item);
$menubar->append($datei);

# Menü zur VBox hinzufügen
$vbox->pack_start($menubar, FALSE, FALSE, 0);

# Hauptfenster anzeigen
$window->show_all;

Gtk3->main;

## Funktion zum Öffnen des Textfensters
sub open_text_window {
    my $top = Gtk3::Window->new('toplevel');
    $top->set_title("Textfenster");
    $top->set_default_size(400, 300);

    my $vbox = Gtk3::Box->new('vertical', 5);
    $vbox->set_border_width(10);
    $top->add($vbox);

    # Scrollbares Textfeld
    my $scrolled_win = Gtk3::ScrolledWindow->new;
    $scrolled_win->set_policy('automatic', 'automatic');

    my $textview = Gtk3::TextView->new;
    $textview->set_editable(0);      # Nicht editierbar
    $textview->set_cursor_visible(0);# Cursor nicht anzeigen

    # Text setzen
    my $buffer = $textview->get_buffer;
    $buffer->set_text("Blahblah");

    $scrolled_win->add($textview);
    $vbox->pack_start($scrolled_win, TRUE, TRUE, 0);

    # Schließen-Button
    my $close_button = Gtk3::Button->new("Schließen");
    $close_button->signal_connect(clicked => sub { $top->destroy });
    $vbox->pack_start($close_button, FALSE, FALSE, 0);

    $top->show_all;
}
