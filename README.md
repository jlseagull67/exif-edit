# exif_edit

A lightweight GTK3-based image browser for Linux that lets you view thumbnails and edit EXIF `Comment` tags directly — no heavyweight photo manager required.

![Perl](https://img.shields.io/badge/Perl-5-blue) ![GTK3](https://img.shields.io/badge/GTK-3-green) ![License](https://img.shields.io/badge/license-Perl--same-lightgrey)

---

## Features

- **Thumbnail grid** — displays all JPEG and PNG images from the current directory in a multi-column grid, scaled to fit your monitor
- **Inline EXIF comment editing** — edit the EXIF `Comment` tag directly in a text field beneath each thumbnail; changes are written automatically when you leave the field
- **EXIF details panel** — click any image to see a curated set of EXIF tags (camera model, lens, focal length, aperture, shutter speed, ISO, date, orientation, and more) in a sidebar
- **Quick "mark for deletion"** — click a filename label to instantly tag the image with `todel` in its EXIF comment
- **Batch move** — the "To Del" menu action moves all `todel`-tagged images into a `todel/` subdirectory and reloads the view
- **Open in external apps** — left-click a thumbnail to open it in Chromium; right-click to open it in GIMP
- **Keyboard shortcuts** — `Ctrl+R` reload, `Ctrl+D` move-to-del, `Ctrl+Q` quit, `Ctrl+H` manual

---

## Screenshots

<img width="2478" height="1443" alt="Bildschirmfoto von 2026-05-12 06 27 16" src="https://github.com/user-attachments/assets/a98a562d-661a-4feb-9d8b-4d34bf519e73" />



---

## Requirements

- Perl 5
- [Gtk3](https://metacpan.org/pod/Gtk3) (`libgtk-3` + Perl bindings)
- [Glib](https://metacpan.org/pod/Glib)
- [Image::ExifTool](https://metacpan.org/pod/Image::ExifTool)
- [Encode](https://metacpan.org/pod/Encode) (core module)
- [POSIX](https://metacpan.org/pod/POSIX) (core module)
- [File::Basename](https://metacpan.org/pod/File::Basename) (core module)
- Chromium (or your prefered Image preview Tool for left-click image preview - see Settings-Section)
- GIMP (or your prefered Image editing Toll for right-click image editing - see Settings-Section)

### Installing Perl dependencies

```bash
# Via cpanm
cpanm Gtk3 Glib Image::ExifTool

# Or via your distro's package manager (Debian/Ubuntu example)
sudo apt install libgtk3-perl libimage-exiftool-perl
```

---

## Installation

```bash
# Clone the repo
git clone https://github.com/youruser/exif_edit.git
cd exif_edit

# Make the script executable
chmod +x exif_edit

# Optionally add it to your PATH
sudo ln -s "$PWD/exif_edit" /usr/local/bin/exif_edit
```

---

## Usage

Navigate to a directory containing images and run:

```bash
exif_edit
```

The window opens maximised, showing thumbnails of all `.jpg`, `.jpeg`, and `.png` files in the current directory.

### Interaction reference

| Action | Result |
|---|---|
| Click anywhere on a thumbnail | Select it — EXIF details appear in the sidebar |
| Left-click a thumbnail | Opens the image in Chromium |
| Right-click a thumbnail | Opens the image in GIMP |
| Edit the text field below a thumbnail, then tab/click away | Saves the new EXIF `Comment` to the file |
| Click the filename label | Sets the comment to `todel` |
| **File → Reload** (`Ctrl+R`) | Rescans the directory and refreshes thumbnails |
| **File → To Del** (`Ctrl+D`) | Moves all `todel`-tagged images to `./todel/` and reloads |
| **File → End** (`Ctrl+Q`) | Quits the application |
| **? → Manual** (`Ctrl+H`) | Opens the built-in manual window |

---

## How the "todel" workflow works

1. Browse your images and click the filename label of any shot you want to discard — this writes `todel` into its EXIF `Comment` field.
2. When you're done reviewing, press **Ctrl+D** (or use File → To Del).
3. All tagged images are moved into a `todel/` subdirectory (created automatically if it doesn't exist).
4. The grid reloads showing only the remaining keepers.

This is non-destructive: the images are moved, not deleted.

---

## Supported EXIF tags (sidebar)

You can choose from all existing tags using the settings menu:

<img width="751" height="1054" alt="Bildschirmfoto von 2026-05-12 06 43 34" src="https://github.com/user-attachments/assets/16445f20-b1c7-4ffd-9351-7012dbb33422" />

(Scroll down for thousands of tags or simply use the Filter funktion)

---

## Settings

Choose from Settings -> Tag Selector to customize the EXIF tags sidebar or even the behavior of the left or right mouse click by setting your prefered image viewing and editing tool or the prefered Exif-Tag that exif_edit creates for your comments (mine is simply Comment).

## License

This program is provided "as is" and may be freely modified or redistributed under the same terms as Perl itself (Artistic License or GPL).

## Author

Jörg Albrecht
