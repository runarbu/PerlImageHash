#!/usr/bin/perl
use strict;
use warnings;

use lib "lib";

use Image::Hash;
use File::Slurp;
use Getopt::Std;
use Tree::BK;
use Data::Dumper; #temp

my %opts;
getopts('vh:m:d:', \%opts);

my $folder = shift @ARGV or die("Pleas spesyfi a start folder!");

# Defines what filetypes we will treat as images
foreach my $type ( qw(png gif jpeg jpg tiff ppm) ) {
	$opts{'imagetypes'}->{$type} = 1;
}

# Counter for holding the number of file we have examined
$opts{'examined'} = 0;

# Max distance to be the same
$opts{'d'} ||= 5;

my @seen;
my %mach;

recdir($folder);


my $tree = Tree::BK->new(\&hammingdistance);


sub hammingdistance {
	my ($a, $b) = @_;

	my $distance = 0;
	for (my $i = 0; $i < 64; $i++) {
		#print $seen[$all]->{'hash'}->[$i] . "<->" . $seen[$one]->{'hash'}->[$i] . "\n";

		if ($a->{'hash'}->[$i] != $b->{'hash'}->[$i]) { 
			$distance++;
		}

	}
	
#	printf("\ta: d=%-2s, g=%-3s (%s)\n", $distance, $a->{'greytones'}, $a->{'file'});
#	printf("\tb: d=%-2s, g=%-3s (%s)\n", $distance, $b->{'greytones'}, $b->{'file'});
#	print "\n";

	return $distance;

}

for (my $all = 0; $all <= $#seen; $all++) {
#	print $seen[$all]->{'file'} . " distances:\n" if $opts{'v'};
	$tree->insert($seen[$all]);
}

print "Stage 2:\n";
my $i = 0;
for (my $all = 0; $all <= $#seen; $all++) {
	if ((++$i % 100) == 0) { print "$i\n"; }

	#print $seen[$all]->{'file'} . " distances:\n";
	my $files = $tree->find($seen[$all],5);

	my @realdup;
	foreach my $dup (@{ $files }) {
		if ($seen[$all]->{'file'} eq $dup->{'file'}) {next;}
		if ($dup->{'greytones'} < 20) {next;}
		#printf("\t %s, distance: %-3s, greytones: %s\n ", $dup->{'file'}, hammingdistance($seen[$all], $dup), $dup->{'greytones'});
		push(@realdup, $dup);
	}

	if ($#realdup == -1) {next;}

	print $seen[$all]->{'file'} . " distances:\n";

	my @convert = ('convert');
	push(@convert, $seen[$all]->{'file'} );

	foreach my $dup (@{ $files }) {
		printf("\t %s, distance: %-3s, greytones: %s\n ", $dup->{'file'}, hammingdistance($seen[$all], $dup), $dup->{'greytones'});
		push(@convert, $dup->{'file'});
	}

	push(@convert, '-append');
	push(@convert, "/tmp/dup/$i.jpeg");
	system(@convert) == 0 or die "system @convert failed: $?";

}
exit;
for (my $all = 0; $all <= $#seen; $all++) {

	print $seen[$all]->{'file'} . " distances:\n" if $opts{'v'};

	for (my $one = 0; $one <= $#seen; $one++) {
		# Skipp if it is the same
		if ($all == $one) {
			next;
		}

		# Find the hamming distance			
		my $distance = 0;
		for (my $i = 0; $i < 64; $i++) {
			#print $seen[$all]->{'hash'}->[$i] . "<->" . $seen[$one]->{'hash'}->[$i] . "\n";

			if ($seen[$all]->{'hash'}->[$i] != $seen[$one]->{'hash'}->[$i]) { 
				$distance++;
			}

		}

		printf("\td=%s, g=%-3s (%s)\n", $distance, $seen[$one]->{'greytones'}, $seen[$one]->{'file'}) if $opts{'v'};


		if ($opts{'d'} >= $distance && $seen[$one]->{'greytones'} > 20) {
			printf("\t%s (%s)\n", $distance, $seen[$one]->{'file'});
			push(@{ $mach{$seen[$all]->{'file'}} }, {'file'=>$seen[$one]->{'file'}, 'distance' => $distance, 'greytones' => $seen[$one]->{'greytones'} });
		}

	}
}

print "\n\nDuplicate files:\n";
$i = 0;
foreach my $key (keys %mach) {

	print "$key ($i): \n";
	my @convert = ('convert');

	push(@convert, $key );
	
	foreach my $dup (@{ $mach{$key} }) {
		printf("\t %s distanse: %s, greytones: %s\n ", $dup->{'file'}, $dup->{'distance'}, $dup->{'greytones'});
		push(@convert, $dup->{'file'});
	}

	push(@convert, '-append');
	push(@convert, "/tmp/dup/$i.jpeg");
	#print "\t\tsystem do: " . join(' ', @convert) . "\n";

	system(@convert) == 0 or die "system @convert failed: $?";

	if ((++$i % 100) == 0) { print "$i\n"; }
}	

###########################################################################################################
#
# Subroutine that recurs thru folders and looks for simular files
#
###########################################################################################################
sub recdir {
	my ($path) = @_;


	my $DIR;
	opendir($DIR, $path) or warn("can't opendir $path: $!") && return;

	while (my $file = readdir($DIR) ) {

		# Return home if we have examined ecnof files
		if ($opts{'m'} && $opts{'examined'} > $opts{'m'}) {
			return;
		}

		#skiping . and ..
		if ($file =~ /\.$/) {
			next;
		}

		my $candidate = $path . "\/" . $file;

		if (-d $candidate) {
			recdir($candidate);
		}
		elsif(-f $candidate) {

			# Find file ending to determine type 
			my $type = $candidate;
			$type =~ s/\.([a-z]+)$//i;
			$type = lc($1);

			# Skipp if we where unable to determine type
			if (!$type) {
				next;
			}

			# Skipp none images
			if (!$opts{'imagetypes'}->{$type}) {
				if ($opts{'v'}) {
					print "Skipped non image file '$candidate' of type '$type'.\n";
				}
				next;
			}

			my $image = read_file( $candidate, binmode => ':raw' ) ;
			
			my $ihash = Image::Hash->new($image);
			
			if (!$ihash) {
				warn("Can't open '$candidate' in Image::Hash.");
				next;
			}
			
			my @hash;

			if ($opts{'v'}) {
				print "$candidate\n";
			}

			if ($opts{'h'} eq 'a') {
				@hash = $ihash->ahash('verbose' => $opts{'v'});
			}
			elsif ($opts{'h'} eq 'p') {
				@hash = $ihash->phash('verbose' => $opts{'v'});
			}
			else {
				@hash = $ihash->dhash('verbose' => $opts{'v'});
			}

			my $greytones = $ihash->greytones();

			push(@seen, {'file' => $candidate, 'hash' => \@hash, 'greytones' => $greytones});
			
			$opts{'examined'}++;
		}
	}

	closedir($DIR);
}
