#!/usr/bin/perl
use strict;
use warnings;

use lib "lib";

use Image::Hash;
use File::Slurp;

my $file = shift @ARGV or die("Pleas spesyfi a file to read!");

my $image = read_file( $file, binmode => ':raw' ) ;

my $ihash = Image::Hash->new($image);

binmode STDOUT;
print STDOUT $ihash->reducedimage();
