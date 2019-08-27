#!perl -w

use Test::More tests => 5;
use strict;

use_ok('NDF');

# Test file
my $file = 'test';

# initialise global status
my $status = &NDF::SAI__OK;

# Initialise NDF
err_begin($status);
ndf_begin();

# Open up the test file
die "Couldn't find test file: $file\n" unless (-e "$file.sdf");

ndf_find(&NDF::DAT__ROOT, $file, my $indf, $status);
is($status, &NDF::SAI__OK, 'Check status after ndf_find');

my $prov = ndgReadProv($indf, 'NDF:test', $status);
is($status, &NDF::SAI__OK, 'Check status after ndgReadProv');

isa_ok($prov, 'NdgProvenancePtr');

# Clean up and close the file
ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
