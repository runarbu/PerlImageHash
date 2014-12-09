#!/usr/bin/perl -w
use strict;
use Imager;
use List::Util qw(sum);
use Data::Dumper;

die "Usage: Imager.pl filename\n" if !-f $ARGV[0];
my $file = shift;

my $format;

# see Imager::Files for information on the read() method
my $img = Imager->new(file=>$file) or die Imager->errstr();

$img = $img->scale(xpixels=>8,ypixels=>8);

my @pixels;
print "Array(\n";
for(my $y=0; $y<8;$y++) {

	print "\t[ ";
	for(my $x=0; $x<8;$x++) {
		if ($x!=0) {print ", ";}

		my @color = $img->getpixel(x => $x, y => $y);
		my ($red, $green, $blue, $alpha) = $color[0]->rgba();
		my $grey = int($red*0.3 + $green*0.59 + $blue*0.11);
		push(@pixels, $grey);
		print $grey;
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
