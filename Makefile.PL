

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Image::Hash',
    VERSION_FROM => 'lib/Image/Hash.pm', # finds \$VERSION
    AUTHOR       => 'Runar Buvik (runarb@gmail.com)',
    ABSTRACT     => 'An image hashing library to calculate an images average hash, perception hash and difference hash.',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
					 'List::Util'	=> 0,
					 'File::Slurp'	=> 0,
					 'GD'			=> 0,
					 'Carp'			=> 0,
                    },
    META_MERGE => {
	'meta-spec' => {
	    version => 2,
	},
        resources => {
            repository => {
		type => 'git',
		url => "git://github.com/runarbu/PerlImageHash.git",
		web => 'https://github.com/runarbu/PerlImageHash',
	    },
        },
    },
);
