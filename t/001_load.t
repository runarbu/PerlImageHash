# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Image::Hash' ); }

my $object = Image::Hash->new ();
isa_ok ($object, 'Image::Hash');


