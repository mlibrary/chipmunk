#!/usr/bin/perl

use File::Basename;

# lightweight ingest for video - just checks file presence and naming
# parameter should be the external ID (unused) and a directory containing a bag
my $EXTERNAL_ID = shift;
my $BAG_DIRECTORY = shift;
my $DIRECTORY = "$BAG_DIRECTORY/data";

my %files = map { basename($_) => 1 } glob("$DIRECTORY/*");

foreach my $required_file ("metadata.yaml") {
    die("$required_file is missing in $DIRECTORY\n") unless defined $files{$required_file};
    delete $files{$required_file};
}

# optional file
delete $files{'closedcaptioning.srt'};

my $seq_ok = 1;
foreach my $i ((1..20)) {
    my $seq = sprintf("%03d",$i);
    if($files{"miam-${EXTERNAL_ID}-$seq.mov"}) {
        delete($files{"miam-${EXTERNAL_ID}-$seq.mov"});
    } else {
        $seq_ok = 0;
    }

    # there can be 1-5 thumbnails per track
    if($files{"mitn-${EXTERNAL_ID}-${seq}_1.jpg"}) {
        delete($files{"mitn-${EXTERNAL_ID}-${seq}_1.jpg"});
    } else {
        $seq_ok = 0;
    }
    foreach my $j ((2..5)) {
        if($files{"mitn-${EXTERNAL_ID}-${seq}_$j.jpg"}) {
            if($seq_ok) {
                delete($files{"mitn-${EXTERNAL_ID}-${seq}_$j.jpg"});
            } else {
                die("Not all files present in $DIRECTORY for seq=$seq but mitn-${EXTERNAL_ID}-${seq}_$j.jpg exists!\n");
            }
        } else { 
            last;
        }
    }
    # optional
    delete($files{"mipm-${EXTERNAL_ID}-${seq}.mov"}) if $seq_ok;

}

# anything left? freak out!
if(keys(%files)) {
    die("Unexpected files " . join(' ',keys(%files)) . " in $DIRECTORY\n");
}

