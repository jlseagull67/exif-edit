#!/usr/bin/perl
use strict;
use warnings;
use Gtk3 '-init';
use Glib qw(TRUE FALSE);

# ─────────────────────────────────────────────────────────────────────────────
# Foto-EXIF-Viewer  –  GTK3 + ExifTool
# Benötigt: libgtk3-perl, libimage-exiftool-perl (oder exiftool im PATH)
# ─────────────────────────────────────────────────────────────────────────────

my $window = Gtk3::Window->new('toplevel');
$window->set_title('Foto EXIF-Viewer');
$window->set_default_size(1100, 700);
$window->set_border_width(0);
$window->signal_connect(destroy => sub { Gtk3->main_quit });

# ── CSS ──────────────────────────────────────────────────────────────────────
my $css = Gtk3::CssProvider->new;
$css->load_from_data(<<'CSS');
window { background-color: #1a1a2e; }
.toolbar { background-color: #16213e; padding: 6px 12px; border-bottom: 1px solid #0f3460; }
button { background-color: #0f3460; color: #e0e0e0; border: 1px solid #e94560; border-radius: 4px; padding: 6px 16px; font-size: 13px; }
button:hover { background-color: #e94560; color: #ffffff; }
.image-area { background-color: #0d0d1a; }
.exif-panel { background-color: #16213e; border-left: 2px solid #0f3460; }
treeview { background-color: #16213e; color: #c9d1d9; font-family: "Monospace"; font-size: 12px; }
treeview:selected { background-color: #e94560; color: #ffffff; }
treeview header button { background-color: #0f3460; color: #58a6ff; border: none; font-weight: bold; font-size: 12px; }
.statusbar { background-color: #0f3460; color: #8b949e; padding: 2px 8px; font-size: 11px; }
label.filename { color: #58a6ff; font-size: 13px; font-weight: bold; }
CSS

# Korrekter Namespace: Gtk3::Gdk::Screen (nicht Gdk3::Screen)
Gtk3::StyleContext::add_provider_for_screen(
    Gtk3::Gdk::Screen::get_default(),
    $css,
    Gtk3::STYLE_PROVIDER_PRIORITY_APPLICATION
);

# ── Layout ───────────────────────────────────────────────────────────────────
my $vbox_main = Gtk3::Box->new('vertical', 0);
$window->add($vbox_main);

my $toolbar = Gtk3::Box->new('horizontal', 8);
$toolbar->get_style_context->add_class('toolbar');
$toolbar->set_border_width(6);

my $btn_open = Gtk3::Button->new_with_label('Foto oeffnen');
my $lbl_file = Gtk3::Label->new('Kein Foto geladen');
$lbl_file->get_style_context->add_class('filename');
$lbl_file->set_halign('start');
$lbl_file->set_hexpand(TRUE);
$toolbar->pack_start($btn_open, FALSE, FALSE, 0);
$toolbar->pack_start($lbl_file, TRUE,  TRUE,  8);
$vbox_main->pack_start($toolbar, FALSE, FALSE, 0);

my $hpaned = Gtk3::Paned->new('horizontal');
$hpaned->set_position(580);
$vbox_main->pack_start($hpaned, TRUE, TRUE, 0);

# ── Bild-Bereich ─────────────────────────────────────────────────────────────
my $scroll_img = Gtk3::ScrolledWindow->new;
$scroll_img->set_policy('automatic', 'automatic');

my $image    = Gtk3::Image->new;
my $eventbox = Gtk3::EventBox->new;
$eventbox->add($image);
$eventbox->get_style_context->add_class('image-area');

my $viewport = Gtk3::Viewport->new(undef, undef);
$viewport->get_style_context->add_class('image-area');
$viewport->add($eventbox);
$scroll_img->add($viewport);
$hpaned->pack1($scroll_img, TRUE, TRUE);

# ── EXIF-Bereich ─────────────────────────────────────────────────────────────
my $exif_box = Gtk3::Box->new('vertical', 0);
$exif_box->get_style_context->add_class('exif-panel');

my $exif_header = Gtk3::Label->new;
$exif_header->set_markup('<span foreground="#58a6ff" font="13" weight="bold">  EXIF-Metadaten</span>');
$exif_header->set_halign('start');
$exif_header->set_margin_top(10);
$exif_header->set_margin_bottom(6);
$exif_box->pack_start($exif_header, FALSE, FALSE, 0);

my $exif_store = Gtk3::ListStore->new('Glib::String', 'Glib::String');
my $exif_view  = Gtk3::TreeView->new_with_model($exif_store);
$exif_view->set_headers_visible(TRUE);
$exif_view->set_grid_lines('horizontal');

for my $col_def (['Tag', 0, 200], ['Wert', 1, 280]) {
    my ($title, $idx, $width) = @$col_def;
    my $renderer = Gtk3::CellRendererText->new;
    $renderer->set(ellipsize => 'end');
    my $col = Gtk3::TreeViewColumn->new_with_attributes($title, $renderer, text => $idx);
    $col->set_min_width($width);
    $col->set_resizable(TRUE);
    $exif_view->append_column($col);
}

my $scroll_exif = Gtk3::ScrolledWindow->new;
$scroll_exif->set_policy('automatic', 'automatic');
$scroll_exif->add($exif_view);
$exif_box->pack_start($scroll_exif, TRUE, TRUE, 0);
$hpaned->pack2($exif_box, FALSE, TRUE);

# ── Statusleiste ──────────────────────────────────────────────────────────────
my $statusbar = Gtk3::Label->new('Bereit');
$statusbar->set_halign('start');
$statusbar->set_margin_start(8);
$statusbar->get_style_context->add_class('statusbar');
$vbox_main->pack_start($statusbar, FALSE, FALSE, 0);

# ─────────────────────────────────────────────────────────────────────────────
# Bild skalieren und anzeigen
# GdkPixbuf ist in Gtk3-Perl als Gtk3::Gdk::Pixbuf erreichbar (via GI)
# ─────────────────────────────────────────────────────────────────────────────
my $current_file = '';

sub show_scaled_image {
    my ($path) = @_;

    my $alloc = $scroll_img->get_allocation;
    my $max_w = ($alloc->{width}  > 10) ? $alloc->{width}  - 4 : 560;
    my $max_h = ($alloc->{height} > 10) ? $alloc->{height} - 4 : 560;

    my $pb = eval { Gtk3::Gdk::Pixbuf->new_from_file($path) };
    if ($@ || !$pb) {
        $statusbar->set_text("Bild konnte nicht geladen werden: $@");
        return;
    }

    my ($w, $h) = ($pb->get_width, $pb->get_height);
    if ($w > $max_w || $h > $max_h) {
        my $scale = ($w / $max_w > $h / $max_h) ? $max_w / $w : $max_h / $h;
        $pb = $pb->scale_simple(int($w * $scale), int($h * $scale), 'bilinear');
    }

    $image->set_from_pixbuf($pb);
}

$scroll_img->signal_connect('size-allocate' => sub {
    show_scaled_image($current_file) if $current_file;
});

# ─────────────────────────────────────────────────────────────────────────────
# EXIF auslesen  (Image::ExifTool Modul)
# ─────────────────────────────────────────────────────────────────────────────
my @WANTED_TAGS = qw(
    FileName
    FileSize
    Model
    LensType
    FocalLength35efl
    LensModel
    FocusDistance
    ImageSize
    ImageStabilization
    Comment
    CreateDate
    Aperture
    ShutterSpeed
    DateTimeOriginal
    ISO
    RollAngle
    Rotation
    Orientation
);
# Hash fuer O(1)-Lookup; nur exakter Tag-Name zaehlt (kein Gruppenpraefix)
my %WANTED = map { $_ => 1 } @WANTED_TAGS;

sub load_exif {
    my ($path) = @_;
    $exif_store->clear;
    my $count = 0;

    # #### Alle Exifs
    # eval {
    #     require Image::ExifTool;
    #     my $et = Image::ExifTool->new;
    #     $et->Options(DateFormat => '%Y-%m-%d %H:%M:%S', Unknown => 1);
    #     my $info = $et->ImageInfo($path);
    #     for my $tag (sort keys %$info) {
    #         my $val = $info->{$tag} // '';
    #         $val = '(binaer)' if ref $val;
    #         $val =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g;
    #         $exif_store->set($exif_store->append, 0, $tag, 1, "$val");
    #         $count++;
    #     }
    # };


    # WANTED_TAGS
       # Duplicates=>0 verhindert, dass ExifTool denselben bare Tag-Namen
    # aus mehreren Gruppen (z.B. EXIF:LensModel + XMP:LensModel) mehrfach
    # liefert und dabei "LensModel (1)" als zweiten Schluessel erzeugt.
    eval {
        require Image::ExifTool;
        my $et = Image::ExifTool->new;
        $et->Options(DateFormat => '%Y-%m-%d %H:%M:%S', Duplicates => 0);
        my $info = $et->ImageInfo($path, \@WANTED_TAGS);
        my %seen;
        for my $raw_tag (@WANTED_TAGS) {
            # ImageInfo mit expliziter Liste liefert Tags ohne Praefix
            next unless exists $info->{$raw_tag};
            (my $bare = $raw_tag) =~ s/.*://;   # Praefix abschneiden
            next if $seen{$bare}++;              # Duplikat ueberspringen
            my $val = $info->{$raw_tag} // '';
            $val = '(binaer)' if ref $val;
            $val =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]//g;
            $exif_store->set($exif_store->append, 0, $bare, 1, "$val");
            $count++;
        }
    }

};

# ── Datei-Dialog ─────────────────────────────────────────────────────────────
$btn_open->signal_connect(clicked => sub {
    my $dialog = Gtk3::FileChooserDialog->new(
        'Foto auswaehlen', $window, 'open',
        'gtk-cancel', 'cancel',
        'gtk-open',   'accept',
    );

    my $filter = Gtk3::FileFilter->new;
    $filter->set_name('Bilder');
    $filter->add_pattern($_) for qw(
        *.jpg *.jpeg *.png *.tiff *.tif *.webp
        *.cr2 *.cr3 *.nef *.arw *.orf *.raf *.dng
        *.JPG *.JPEG *.PNG *.TIFF *.TIF
    );
    $dialog->add_filter($filter);

    my $all = Gtk3::FileFilter->new;
    $all->set_name('Alle Dateien');
    $all->add_pattern('*');
    $dialog->add_filter($all);

    if ($dialog->run eq 'accept') {
        my $file = $dialog->get_filename;
        $dialog->destroy;

        $statusbar->set_text("Lade $file ...");
        Gtk3::main_iteration() while Gtk3::events_pending();

        $current_file = $file;
        show_scaled_image($file);

        (my $basename = $file) =~ s{.*/}{};
        $lbl_file->set_text($basename);

        my $n = load_exif($file);
        $statusbar->set_text($n
            ? "$basename  -  $n EXIF-Tags geladen"
            : "$basename  -  Keine EXIF-Daten (exiftool installiert?)");
    } else {
        $dialog->destroy;
    }
});

# ── Start ─────────────────────────────────────────────────────────────────────
$window->show_all;
Gtk3->main;
