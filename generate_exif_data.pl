#!/usr/bin/perl -w

use strict;
use lib "/usr/bin/lib";
use Getopt::Std;
use Image::ExifTool qw( ImageInfo );
use Data::Dumper;

use vars qw( %opts $photo_dir $www_dir $www_month_dir @new $exif );

$opts{t} = "";
getopts( 'hm:n:t:', \%opts ) or usage();

$photo_dir = '/Users/mkns/Pictures/Photos/' . $opts{m} . '/';
$www_dir = '/Users/mkns/Pictures/www/';
$www_month_dir = $www_dir . $opts{m} . '/';
@new = ();
$exif = {};

print "Generating exif data...\n";
opendir( DIR, $www_month_dir ) or die $!;
foreach my $file ( sort readdir( DIR ) ) {
  next if $file =~ /^(\.|thumb|Thumbs|CVS|exif)/;
  my $real_photo = $photo_dir . '/' . $file;
  my $info = ImageInfo( $real_photo );
  undef $info->{ThumbnailImage};
  undef $info->{PreviewImage};
  $exif->{$file} = $info;
}
open( FILE, "> " . $www_month_dir . "/exif.txt" ) or die $!;
print FILE Dumper( $exif );
close( FILE );
