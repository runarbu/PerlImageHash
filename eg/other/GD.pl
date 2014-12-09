#!/usr/bin/perl -w
use strict;
use GD;
use Data::Dumper;
use List::Util qw(sum);

die "Usage: GD.pl filename\n" if !-f $ARGV[0];
my $file = shift;

my $format;

my $img = GD::Image->new($file) or die("Can't load file");

# Resize to 8x8
$img->copyResized($img, 0, 0, 0, 0, 8, 8, $img->getBounds);

my @pixels;
print "Array(\n";
for(my $y=0; $y<8;$y++) {
	print "\t[ ";
	for(my $x=0; $x<8;$x++) {
		if ($x!=0) {print ", ";}

		my $color = $img->getPixel($x, $y);
		my ($red, $green, $blue) = $img->rgb($color);
		my $grey = int($red*0.3 + $green*0.59 + $blue*0.11);
		push(@pixels, $grey);
		printf("%3s", $grey);
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
