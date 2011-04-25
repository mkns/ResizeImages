#!/usr/bin/perl -w

use strict;
use lib "/usr/bin/lib";
use Getopt::Std;
use Image::ExifTool qw( ImageInfo );
use Safe;
use Data::Dumper;
use POSIX;

use vars qw( %opts $photo_dir $www_dir $www_month_dir @new $exif );

getopts( 'hm:', \%opts ) or usage();
usage() if !defined( $opts{m} );

$photo_dir = '/Users/mkns/Pictures/Photos/' . $opts{m} . '/';
$www_dir = '/Users/mkns/Pictures/www/';
$www_month_dir = $www_dir . $opts{m} . '/';

print "Setting timestamps...\n";

my $exif_file = $www_dir . $opts{m} . "/exif.txt";
my $exif = load_cfg( $exif_file );

foreach my $photo ( sort keys %$exif ) {
  my $fulldate = $exif->{$photo}->{DateTimeOriginal} || $exif->{$photo}->{CreateDate};
  my ( $date, $time ) = split( " ", $fulldate );
  my ( $year, $month, $day ) = split( ":", $date );
  my ( $hour, $minute, $second ) = split( ":", $time );
  my $timestamp = mktime( $second, $minute, $hour, $day, $month - 1, $year - 1900 );
  print "$photo $fulldate $timestamp\n";
  utime $timestamp, $timestamp, $www_month_dir . $photo;
  utime $timestamp, $timestamp, $www_month_dir . "/thumbnails/" . $photo;
}

sub usage {
  die "Need a month...";
}

sub load_cfg {
    my ( $cfg_file ) = @_;
    my $cpt = new Safe;

  # read in the file and untaint it

    local(*IN, $/);
    undef $/;
    open(IN, $cfg_file) || die "Failed to open $cfg_file: $!";
    my $c = <IN>;
    close(IN);

  $c = $1 if ( $c =~ m/(.*)/s );

    my $cfg = $cpt->reval( $c );

  die "Failed to load cfg-file $cfg_file: $@"
      if ( $@ );

  die "Failed to load cfg-file $cfg_file"
      unless ( defined $cfg );

    return $cfg;
}
