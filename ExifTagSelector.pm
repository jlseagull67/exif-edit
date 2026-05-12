package ExifTagSelector;

use strict;
use warnings;
use utf8;
use Encode     qw(decode);
use Gtk3;
use YAML::Tiny;
use File::Basename qw(dirname);
use File::Path     qw(make_path);
use Exporter 'import';

our @EXPORT_OK = qw(show_tag_selector load_config);

# ------------------------------------------------------------------ #
#  Config-File                                                         #
# ------------------------------------------------------------------ #
my $CONFIG_FILE = $ENV{HOME} . '/.config/exif_selector/config.yaml';

sub config_file { $CONFIG_FILE }

# ------------------------------------------------------------------ #
#  Helper                                                              #
# ------------------------------------------------------------------ #
sub u8 { decode('UTF-8', $_[0]) }

# ------------------------------------------------------------------ #
#  All known ExifTool-Tags (grouped by Category)                       #
# ------------------------------------------------------------------ #
my %TAG_GROUPS = (
    'ACDSee / Software-specific' => [qw(
        ACDSeeRegion ACDSeeRegionName ACDSeeRegionType
        ACDSeeRegionALGArea ACDSeeRegionDLYArea
        ACDSeeRegionAppliedToDimensions
    )],
    'AF – Autofocus' => [qw(
        AFPoint AFPointInFocus AFPointSelected AFPointMode AFPointSel
        AFArea AFAreaMode AFAreaModeSetting AFAreaSelectMethod
        AFAssist AFAssistBeam AFAssistLamp
        AFFineTune AFFineTuneAdj AFFineTuneAdjTele
        AFMicroAdj AFMicroAdjMode AFMicroAdjValue AFMicroadjustment
        AFMode AFPerformance AFResponse AFResult AFSearch
        AFSubjectDetection AFTrackingMode
        AFHold AFDuringLiveView AFActivation AFButtonPressed
        AFConfidence AFInFocus AFStatus AFStable
        AFImageHeight AFImageWidth
    )],
    'Audio – Metadata' => [qw(
        AudioCodec AudioBitrate AudioChannels AudioSampleRate
        AudioStreamType AudioStreamDuration AudioStreamFrameCount
        SoundFormat Channels SampleRate SampleSize
        WMADRCAverageReference WMADRCAverageTarget
        WMADRCPeakReference WMADRCPeakTarget
        Balance Balance1 Balance2
    )],
    'Composite / Calculated Values' => [qw(
        Aperture ShutterSpeed LightValue
        FocalLength35efl HyperfocalDistance
        ScaleFactor35efl CircleOfConfusion DOF
        GPSPosition Megapixels ImageSize
        RunTimeSincePowerUp
    )],
    'DICOM / Medicin' => [qw(
        PatientName PatientID PatientBirthDate PatientSex PatientAge
        PatientWeight StudyDescription SeriesDescription
        StudyDate StudyTime StudyID
        Modality Manufacturer ManufacturerModelName
        InstitutionName InstitutionAddress
        ReferringPhysicianName PerformingPhysicianName
        StudyInstanceUID SeriesInstanceUID SOPInstanceUID SOPClassUID
        BodyPartExamined
        KVP ExposureTime XRayTubeCurrent
        WindowCenter WindowWidth
        SliceThickness SliceLocation
        PixelSpacing PixelAspectRatio
        Rows Columns NumberOfFrames BitsAllocated BitsStored
        PhotometricInterpretation
        ImagePositionPatient ImageOrientationPatient
    )],
    'Drone / UAV' => [qw(
        DroneModel DroneSerialNumber DroneID
        FlightMode FlightTime FlightXSpeed FlightYSpeed FlightZSpeed
        CameraModel GimbalDegree GimbalPitchDegree GimbalRollDegree GimbalYawDegree
        RelativeAltitude AbsoluteAltitude
        Pitch Roll Yaw PitchAngle RollAngle YawAngle
        GimbalReverse SelfData HorizonLevelData
        SpeedX SpeedY SpeedZ
        WindSpeed WindDirection WindMode
        BatteryPercent BatteryTemperature MotorOnTime
    )],
    'EXIF – Camera &amp; Recording' => [qw(
        Make Model LensModel LensID LensMake
        Software SerialNumber CameraSerialNumber
        ExposureTime FNumber ISO ExposureProgram ExposureMode
        ExposureCompensation MeteringMode LightSource Flash
        FocalLength FocalLengthIn35mmFormat
        MaxApertureValue ApertureValue ShutterSpeedValue
        BrightnessValue SubjectDistance
        WhiteBalance DigitalZoomRatio SceneCaptureType
        Contrast Saturation Sharpness
        ColorSpace ColorComponents
    )],
    'EXIF-Edit specific' => [qw(
        Comment
    )],
    'EXIF – Date &amp; Time' => [qw(
        DateTimeOriginal CreateDate ModifyDate
        SubSecTime SubSecTimeOriginal SubSecTimeDigitized
        OffsetTime OffsetTimeOriginal
    )],
    'EXIF – Picture-Properties' => [qw(
        ImageWidth ImageHeight ExifImageWidth ExifImageHeight
        Orientation ResolutionUnit XResolution YResolution
        BitsPerSample SamplesPerPixel PhotometricInterpretation
        Compression CompressedBitsPerPixel
        YCbCrPositioning YCbCrSubSampling
    )],
    'EXIF – GPS' => [qw(
        GPSLatitude GPSLongitude GPSAltitude GPSAltitudeRef
        GPSLatitudeRef GPSLongitudeRef
        GPSTimeStamp GPSDateStamp GPSStatus
        GPSMeasureMode GPSDOP GPSSpeed GPSSpeedRef
        GPSTrack GPSTrackRef GPSImgDirection GPSImgDirectionRef
        GPSMapDatum GPSDestLatitude GPSDestLongitude
        GPSDestBearing GPSDestDistance GPSProcessingMethod
        GPSHPositioningError
    )],
    'File-Information' => [qw(
        FileName FileSize FileModifyDate FileAccessDate
        FileCreateDate FileType FileTypeExtension MIMEType
    )],
    'GPS – Advanced' => [qw(
        GPSCoordinates GPSAltitudeMeter GPSCoordinate
        GPSPosition2 GPSDateTime GPSValid
        AccelerationX AccelerationY AccelerationZ
        AngularVelocityX AngularVelocityY AngularVelocityZ
        WheelspeedLeftDriven WheelspeedRightDriven
        WaterDepth
        LocationName LocationCity LocationState LocationCountry
        LocationCreatedCity LocationCreatedCountryCode
        LocationCreatedCountryName LocationCreatedProvinceState
        LocationShownCity LocationShownCountryCode
        LocationShownCountryName LocationShownProvinceState
        LocationShownSublocation
    )],
    'ICC – Colorprofile' => [qw(
        ProfileDescription ProfileCopyright ProfileVersion
        ProfileClass ProfileConnectionSpace ProfileCreator ProfileID
        ProfileDateTime ProfileFileSignature ProfileFlags
        ColorSpaceData RenderingIntent ConnectionSpaceIlluminant
        MediaWhitePoint MediaBlackPoint DeviceManufacturer DeviceModel
        ViewingCondDesc ViewingCondIlluminant
        Luminance MeasurementObserver MeasurementBacking
        MeasurementGeometry MeasurementFlare MeasurementIlluminant
        ChromaticAdaptation RedTRC GreenTRC BlueTRC
        RedMatrixColumn GreenMatrixColumn BlueMatrixColumn
        ProfilePCS ProfileID ProfileSize
    )],
    'IPTC – Editorial Data' => [qw(
        ObjectName Caption-Abstract Keywords
        Category SupplementalCategories
        Byline BylineTitle Credit Source
        CopyrightNotice Contact
        Headline SpecialInstructions
        DateCreated TimeCreated
        City Sub-location Province-State Country-PrimaryLocationCode
        Country-PrimaryLocationName OriginalTransmissionReference
        EditStatus FixtureIdentifier
        Writer-Editor ImageType
    )],
    'IPTC – Extensions (IPTC4XMP)' => [qw(
        ArtworkOrObject ArtworkCopyrightNotice ArtworkCreator
        ArtworkDateCreated ArtworkSource ArtworkSourceInventoryNo
        ArtworkTitle ContentWarning
        CvTerm CvTermCvId CvTermId CvTermName CvTermRefinedAbout
        DigitalImageGUID DigitalSourceType
        EmbdEncRightsExpr EncRightsExpr
        EntityWithRole EventExt
        LinkedEncRightsExpr
        PersonInImage PersonInImageWDetails
        ProductInImage ProductInImageDescription ProductInImageGTIN
        ProductInImageName
        RegionBoundaryH RegionBoundaryShape RegionBoundaryUnit
        RegionBoundaryW RegionBoundaryX RegionBoundaryY
        RegistryEntryRole RegistryID RegistryOrganisationID
        RightsExprEncType RightsExprLangID
        Source LocationCreated LocationShown
        MaxAvailHeight MaxAvailWidth
    )],
    'JFIF / JPEG-Internals' => [qw(
        JFIFVersion ResolutionUnit XResolution YResolution
        Comment APP0 APP1 APP2 APP14
        EncodingProcess ColorComponents
        DCTEncodeVersion APP12_FlashUsed APP12_FirmwareVersion
        APP12_CameraModel APP12_Miscellaneous
    )],
    'MakerNotes' => [qw(
        MakerNote CanonModelID NikonType2
        SonyModelID OlympusModelID PanasonicModelID
        FujiFilmModelID PentaxModelID
    )],
    'Olympus Specific' => [qw(
        LensType FocusDistance FocalLength35efl
        ImageStabilization RollAngle
    )],
    'Panorama &amp; Stitching' => [qw(
        PanoramaMode PanoramaDirection PanoramaFieldOfView
        PanoramaSourceImages PanoramaSourceWidth PanoramaSourceHeight
        PanoramaCropTop PanoramaCropBottom PanoramaCropLeft PanoramaCropRight
        PanoramaFullWidth PanoramaFullHeight
        StitchingInfo LevelAngle PoseRollDegrees PosePitchDegrees
        FullPanoWidthPixels FullPanoHeightPixels
        CroppedAreaLeftPixels CroppedAreaTopPixels
        CroppedAreaImageWidthPixels CroppedAreaImageHeightPixels
        LargestValidInteriorRectLeft LargestValidInteriorRectTop
        LargestValidInteriorRectWidth LargestValidInteriorRectHeight
        ProjectionType UsePanoramaViewer CaptureSoftware
    )],
    'Thumbnail &amp; Preview' => [qw(
        ThumbnailImage ThumbnailOffset ThumbnailLength
        ThumbnailImageSize PreviewImageSize
        JpgFromRaw OtherImage
    )],
    'Various' => [qw(
        Rating RatingPercent Label Urgency
        PickLabel ColorLabel
        Keyword Subject Tag Category Tags
        Description Title Caption Abstract
        Marked Watched Flag
        WebStatement CopyrightURL UsageTerms
        CreateDate ModifyDate MetadataDate
        PageCount WordCount CharacterCount ParagraphCount
        Language LanguageCode
        Author Creator Publisher
        SoftwareVersion ApplicationVersion
        Warning Error
    )],
    'Video – Recording &amp; Codec' => [qw(
        VideoCodec VideoFrameRate VideoAvgFrameRate
        VideoScanType VideoFieldOrder VideoColorimetry
        VideoStreamType VideoStreamFrameCount VideoStreamDuration
        MediaDuration MediaDataSize MediaDataOffset
        MatrixCoefficients TransferCharacteristics ColourPrimaries
        VideoFullRangeFlag AspectRatioX AspectRatioY
        BitDepth BitRate MaxBitrate NominalBitrate
        HandlerDescription HandlerType HandlerVendorID
        TrackDuration TrackModifyDate TrackCreateDate
        MovieHeaderVersion MovieDuration
    )],
    'White Balance – Rawdata' => [qw(
        WB_RGBLevels WB_RGBLevelsAsShot WB_RGBLevelsAuto
        WB_RGBLevelsDaylight WB_RGBLevelsFlash WB_RGBLevelsFluorescent
        WB_RGBLevelsTungsten WB_RGBLevelsCloudy
        WB_RGGBLevels WB_RGGBLevelsAsShot WB_RGGBLevelsDaylight
        WB_RGGBLevelsFlash WB_RGGBLevelsFluorescent
        WB_RGGBLevelsTungsten WB_RGGBLevelsCloudy
        WB_RBLevels WB_RBLevelsAsShot WB_RBLevelsDaylight
        WhiteBalance WhiteBalanceAdj WhiteBalanceBias
        WhiteBalanceFineTune WhiteBalanceMode WhiteBalanceSet
        WhiteBalanceSetting WhiteBalanceTable WhiteBalanceTemperature
        WhitePoint WhiteLevel
    )],
    'XMP – Camera (exif/aux)' => [qw(
        XMP:ExposureTime XMP:FNumber XMP:ExposureProgram
        XMP:ISOSpeedRatings XMP:DateTimeOriginal
        XMP:FocalLength XMP:Flash XMP:WhiteBalance
        XMP:LensModel XMP:LensID XMP:LensInfo
        XMP:SerialNumber XMP:Firmware
    )],
    'XMP – Dublin Core &amp; Rights' => [qw(
        XMP:Title XMP:Description XMP:Subject XMP:Creator
        XMP:Rights XMP:Source XMP:Identifier XMP:Language
        XMP:Publisher XMP:Relation XMP:Coverage XMP:Format
        XMP:Type
    )],
    'XMP – Lightroom / CRS' => [qw(
        XMP:ProcessVersion XMP:WhiteBalance
        XMP:Temperature XMP:Tint
        XMP:Exposure2012 XMP:Contrast2012
        XMP:Highlights2012 XMP:Shadows2012
        XMP:Whites2012 XMP:Blacks2012
        XMP:Clarity2012 XMP:Dehaze
        XMP:Vibrance XMP:Saturation
        XMP:HueAdjustmentRed XMP:SaturationAdjustmentRed
        XMP:LuminanceAdjustmentRed
        XMP:SharpenRadius XMP:SharpenDetail XMP:SharpenEdgeMasking
        XMP:LuminanceSmoothing XMP:ColorNoiseReduction
        XMP:LensProfileEnable XMP:LensProfileSetup
        XMP:PerspectiveVertical XMP:PerspectiveHorizontal
        XMP:VignetteAmount XMP:GrainAmount
        XMP:Rating XMP:Label XMP:PickLabel
    )],
    'XMP – Media Management' => [qw(
        XMP:DocumentID XMP:InstanceID XMP:OriginalDocumentID
        XMP:DerivedFrom XMP:History XMP:ManagedFrom
        XMP:Manager XMP:ManageTo XMP:ManageUI
        XMP:RenditionClass XMP:RenditionParams
        XMP:VersionID XMP:Versions XMP:LastURL
        XMP:RenditionOf XMP:SaveID
    )],
    'XMP – PLUS Licence' => [qw(
        XMP:CopyrightOwner XMP:ImageCreator XMP:ImageSupplier
        XMP:ImageSupplierID XMP:ImageSupplierImageID
        XMP:LicensorID XMP:LicensorName XMP:LicensorURL
        XMP:LicensorEmail XMP:LicensorTelephone
        XMP:LicenseeID XMP:LicenseeName
        XMP:LicenseStartDate XMP:LicenseEndDate
        XMP:MediaSummaryCode XMP:DigitalSourceType
        XMP:ModelReleaseID XMP:ModelReleaseStatus
        XMP:PropertyReleaseID XMP:PropertyReleaseStatus
        XMP:Reuse XMP:OtherConstraints
    )],
    'XMP – Photoshop &amp; Bridge' => [qw(
        XMP:ColorMode XMP:ICCProfile
        XMP:DateCreated XMP:Credit XMP:Source
        XMP:Headline XMP:Instructions XMP:TransmissionReference
        XMP:Category XMP:SupplementalCategories
        XMP:CaptionWriter XMP:City XMP:State XMP:Country
        XMP:AuthorsPosition
    )],
);

my @GROUP_ORDER = (
    'File-Information',
    'EXIF-Edit specific',
    'Olympus Specific',
    'EXIF – Camera &amp; Recording',
    'EXIF – Date &amp; Time',
    'EXIF – Picture-Properties',
    'EXIF – GPS',
    'GPS – Advanced',
    'AF – Autofocus',
    'White Balance – Rawdata',
    'IPTC – Editorial Data',
    'IPTC – Extensions (IPTC4XMP)',
    'XMP – Dublin Core &amp; Rights',
    'XMP – Camera (exif/aux)',
    'XMP – Photoshop &amp; Bridge',
    'XMP – Lightroom / CRS',
    'XMP – Media Management',
    'XMP – PLUS Licence',
    'ICC – Colorprofile',
    'Panorama &amp; Stitching',
    'Drone / UAV',
    'Video – Recording &amp; Codec',
    'Audio – Metadata',
    'ACDSee / Software-specific',
    'DICOM / Medicin',
    'JFIF / JPEG-Internals',
    'Various',
    'Composite / Calculated Values',
    'Thumbnail &amp; Preview',
    'MakerNotes',
);

# ------------------------------------------------------------------ #
#  Load / Save Config                                                  #
# ------------------------------------------------------------------ #
sub load_config {
    return ({}, {}) unless -f $CONFIG_FILE;
    my $yaml = YAML::Tiny->read($CONFIG_FILE);
    return ({}, {}) unless $yaml && $yaml->[0];
    my $cfg = $yaml->[0];
    my %selected;
    if (ref $cfg->{selected_tags} eq 'ARRAY') {
        $selected{$_} = 1 for @{ $cfg->{selected_tags} };
    }
    my %settings = (
        action_left_mousebutton   => $cfg->{action_left_mousebutton}   // '',
        action_right_mousebutton  => $cfg->{action_right_mousebutton}  // '',
        name_of_exif_edit_comment => $cfg->{name_of_exif_edit_comment} // '',
    );
    return (\%selected, \%settings);
}

sub save_config {
    my ($selected_ref, $settings_ref) = @_;
    my @tags = sort keys %$selected_ref;
    my $dir  = dirname($CONFIG_FILE);
    make_path($dir) unless -d $dir;
    my $yaml = YAML::Tiny->new({
        selected_tags             => \@tags,
        action_left_mousebutton   => $settings_ref->{action_left_mousebutton}   // '',
        action_right_mousebutton  => $settings_ref->{action_right_mousebutton}  // '',
        name_of_exif_edit_comment => $settings_ref->{name_of_exif_edit_comment} // '',
        saved_at                  => scalar localtime,
    });
    $yaml->write($CONFIG_FILE);
    return scalar @tags;
}

# ------------------------------------------------------------------ #
#  Public: show_tag_selector($parent_window)                           #
#  Öffnet das Fenster (einmalig erzeugt, danach per present() reused)  #
# ------------------------------------------------------------------ #
{
    my $selector_window;   # wird beim ersten Aufruf erzeugt

    sub show_tag_selector {
        my ($parent) = @_;

        if (defined $selector_window) {
            $selector_window->present();
            return;
        }

        my %checkboxes;
        my %selected_tags;
        my ($prev, $prev_settings) = load_config();
        %selected_tags = %$prev;

        # ---- Fenster ----
        $selector_window = Gtk3::Window->new('toplevel');
        $selector_window->set_title("ExifTool \x{2013} Tag-Selection");
        $selector_window->set_default_size(750, 700);
        $selector_window->set_border_width(0);
        $selector_window->set_transient_for($parent);
        # Beim Schließen nur verstecken, nicht zerstören
        $selector_window->signal_connect(delete_event => sub {
            $selector_window->hide();
            return 1;  # verhindert destroy
        });

        my $outer_vbox = Gtk3::Box->new('vertical', 0);
        $selector_window->add($outer_vbox);

        # ---- General Settings ----
        my $gs_title_label = Gtk3::Label->new('');
        $gs_title_label->set_markup('<span weight="bold" size="14336">General Settings</span>');
        $gs_title_label->set_halign('start');
        my $gs_title_box = Gtk3::Box->new('horizontal', 12);
        $gs_title_box->set_border_width(14);
        $gs_title_box->pack_start($gs_title_label, 1, 1, 0);
        $outer_vbox->pack_start($gs_title_box, 0, 0, 0);

        my $gs_grid = Gtk3::Grid->new();
        $gs_grid->set_column_spacing(12);
        $gs_grid->set_row_spacing(8);
        $gs_grid->set_border_width(14);
        $gs_grid->set_margin_top(0);
        $outer_vbox->pack_start($gs_grid, 0, 0, 0);

        my $lbl_comment = Gtk3::Label->new(u8('Name of the EXIF-Edit-Comment:'));
        $lbl_comment->set_halign('start');
        my $entry_comment = Gtk3::Entry->new();
        $entry_comment->set_placeholder_text(u8('i.e. Comment'));
        $entry_comment->set_hexpand(1);
        $gs_grid->attach($lbl_comment,   0, 0, 1, 1);
        $gs_grid->attach($entry_comment, 1, 0, 1, 1);

        my $lbl_left = Gtk3::Label->new(u8('Action of Left Mouse Button:'));
        $lbl_left->set_halign('start');
        my $entry_left = Gtk3::Entry->new();
        $entry_left->set_placeholder_text(u8('i.e. Chromium'));
        $entry_left->set_hexpand(1);
        $gs_grid->attach($lbl_left,   0, 1, 1, 1);
        $gs_grid->attach($entry_left, 1, 1, 1, 1);

        my $lbl_right = Gtk3::Label->new(u8('Action of Right Mouse Button:'));
        $lbl_right->set_halign('start');
        my $entry_right = Gtk3::Entry->new();
        $entry_right->set_placeholder_text(u8('i.e. gimp'));
        $entry_right->set_hexpand(1);
        $gs_grid->attach($lbl_right,   0, 2, 1, 1);
        $gs_grid->attach($entry_right, 1, 2, 1, 1);

        $entry_comment->set_text($prev_settings->{name_of_exif_edit_comment});
        $entry_left->set_text($prev_settings->{action_left_mousebutton});
        $entry_right->set_text($prev_settings->{action_right_mousebutton});

        $outer_vbox->pack_start(Gtk3::Separator->new('horizontal'), 0, 0, 0);

        # ---- Header Tag-Selection ----
        my $header = Gtk3::Box->new('horizontal', 12);
        $header->set_border_width(14);
        my $title_label = Gtk3::Label->new('');
        $title_label->set_markup('<span weight="bold" size="14336">ExifTool Tag-Selection</span>');
        $title_label->set_halign('start');
        $header->pack_start($title_label, 1, 1, 0);
        my $status_label = Gtk3::Label->new('');
        $status_label->set_halign('end');
        $header->pack_end($status_label, 0, 0, 0);
        $outer_vbox->pack_start($header, 0, 0, 0);

        $outer_vbox->pack_start(Gtk3::Separator->new('horizontal'), 0, 0, 0);

        # ---- Search Box ----
        my $search_box = Gtk3::Box->new('horizontal', 8);
        $search_box->set_border_width(10);
        my $search_entry = Gtk3::SearchEntry->new();
        $search_entry->set_placeholder_text('Filter Tags …');
        $search_entry->set_hexpand(1);
        $search_box->pack_start($search_entry, 1, 1, 0);
        my $btn_select_all   = Gtk3::Button->new_with_label('Mark All');
        my $btn_deselect_all = Gtk3::Button->new_with_label('Deselect All');
        $search_box->pack_start($btn_select_all,   0, 0, 0);
        $search_box->pack_start($btn_deselect_all, 0, 0, 0);
        $outer_vbox->pack_start($search_box, 0, 0, 0);

        # ---- Scrollbarer Bereich mit Checkboxen ----
        my $scrolled = Gtk3::ScrolledWindow->new(undef, undef);
        $scrolled->set_policy('never', 'automatic');
        $scrolled->set_vexpand(1);
        $outer_vbox->pack_start($scrolled, 1, 1, 0);

        my $main_vbox = Gtk3::Box->new('vertical', 0);
        $main_vbox->set_border_width(10);
        $scrolled->add($main_vbox);

        # ---- Status-Update ----
        my $update_status = sub {
            my $count = scalar keys %selected_tags;
            $status_label->set_text("$count Tag(s) selected");
        };

        # ---- Gruppen & Checkboxen aufbauen ----
        for my $group (@GROUP_ORDER) {
            next unless exists $TAG_GROUPS{$group};

            my $group_label = Gtk3::Label->new("<b>$group</b>");
            $group_label->set_use_markup(1);
            $group_label->set_halign('start');
            $group_label->set_margin_top(14);
            $group_label->set_margin_bottom(4);
            $main_vbox->pack_start($group_label, 0, 0, 0);
            $main_vbox->pack_start(Gtk3::Separator->new('horizontal'), 0, 0, 0);

            my $grid = Gtk3::Grid->new();
            $grid->set_column_spacing(16);
            $grid->set_row_spacing(2);
            $grid->set_margin_top(4);
            $main_vbox->pack_start($grid, 0, 0, 0);

            my ($col, $row) = (0, 0);
            for my $tag (sort @{ $TAG_GROUPS{$group} }) {
                my $cb = Gtk3::CheckButton->new_with_label($tag);
                $cb->set_active(1) if $selected_tags{$tag};
                $cb->set_hexpand(1);
                $cb->signal_connect(toggled => sub {
                    if ($cb->get_active) { $selected_tags{$tag} = 1; }
                    else                 { delete $selected_tags{$tag}; }
                    $update_status->();
                });
                $grid->attach($cb, $col, $row, 1, 1);
                $checkboxes{$tag} = $cb;
                $col++;
                if ($col >= 3) { $col = 0; $row++; }
            }
        }

        $update_status->();

        # ---- Footer ----
        $outer_vbox->pack_start(Gtk3::Separator->new('horizontal'), 0, 0, 0);
        my $footer = Gtk3::Box->new('horizontal', 10);
        $footer->set_border_width(12);
        my $info_label = Gtk3::Label->new('');
        $info_label->set_markup(u8('<span size="10240">Configuration: ' . $CONFIG_FILE . '</span>'));
        $info_label->set_halign('start');
        $info_label->set_ellipsize('start');
        $footer->pack_start($info_label, 1, 1, 0);

        my $btn_save  = Gtk3::Button->new_with_label('Save');
        $btn_save->get_style_context->add_class('suggested-action');
        my $btn_close = Gtk3::Button->new_with_label('Close');
        $footer->pack_end($btn_close, 0, 0, 0);
        $footer->pack_end($btn_save,  0, 0, 0);
        $outer_vbox->pack_start($footer, 0, 0, 0);

        # ---- Signal-Handler ----
        $search_entry->signal_connect('search-changed' => sub {
            my $term = lc($search_entry->get_text());
            for my $tag (keys %checkboxes) {
                my $cb = $checkboxes{$tag};
                if ($term eq '' || index(lc($tag), $term) >= 0) { $cb->show(); }
                else                                             { $cb->hide(); }
            }
        });

        $btn_select_all->signal_connect(clicked => sub {
            for my $tag (keys %checkboxes) {
                my $cb = $checkboxes{$tag};
                next unless $cb->is_visible;
                $cb->set_active(1);
                $selected_tags{$tag} = 1;
            }
            $update_status->();
        });

        $btn_deselect_all->signal_connect(clicked => sub {
            for my $tag (keys %checkboxes) {
                my $cb = $checkboxes{$tag};
                next unless $cb->is_visible;
                $cb->set_active(0);
                delete $selected_tags{$tag};
            }
            $update_status->();
        });

        $btn_save->signal_connect(clicked => sub {
            my %settings = (
                action_left_mousebutton   => $entry_left->get_text(),
                action_right_mousebutton  => $entry_right->get_text(),
                name_of_exif_edit_comment => $entry_comment->get_text(),
            );
            my $count = save_config(\%selected_tags, \%settings);
            my $dialog = Gtk3::MessageDialog->new(
                $selector_window, 'destroy-with-parent', 'info', 'ok',
                "$count Tag(s) saved in config."
            );
            $dialog->set_title('Saved');
            $dialog->run;
            $dialog->destroy;
        });

        $btn_close->signal_connect(clicked => sub { $selector_window->hide() });

        $selector_window->show_all();
        $selector_window->present();
    }
}

1;
