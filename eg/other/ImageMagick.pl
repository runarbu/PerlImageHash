#!/usr/bin/perl -w
use strict;
use Image::Magick;
use Data::Dumper;
use List::Util qw(sum);

die "Usage: GD.pl filename\n" if !-f $ARGV[0];
my $file = shift;

my $format;

my $img = Image::Magick->new();
$img->Read($file);

# Resize to 8x8
$img->Resize(geometry=>'8x8');

my @pixels;
print "Array(\n";
for(my $y=0; $y<8;$y++) {
	print "\t[ ";
	for(my $x=0; $x<8;$x++) {
		if ($x!=0) {print ", ";}

		my @pixel = $img->GetPixel(x=>$x,y=>$y,normalize => 0);
		my $grey = $pixel[0]*0.3 + $pixel[1]*0.59 + $pixel[2]*0.11;
		push(@pixels, $grey);
		printf("%3s", int( $grey / 256) );
	}
	print " ]\n";
}
print ")\n";


# Make the aHash
my $m = sum(@pixels)/@pixels;
my $binvalue = '';

foreach my $p (@pixels) {
	if ($p > $m) {
		$binvalue .= '1';
	}
	else {
		$binvalue .= '0';
	}
}

print "Hash: " . $binvalue . "\n";
