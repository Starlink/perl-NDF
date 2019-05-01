#!perl -w

use Test::More tests => 6;
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
is($status, &NDF::SAI__OK, 'Check status');

ndf_xloc($indf, 'REDS', 'READ', my $xloc, $status);
is($status, &NDF::SAI__OK, 'Check status after xloc');

cmp_get0c($xloc, 'SUB_INSTRUMENT', my $cmp_value, $status);
is($cmp_value, 'LONG', 'cmp_get0c value');

cmp_type($xloc, 'SUB_INSTRUMENT', my $cmp_type, $status);
is($cmp_type, '_CHAR*15', 'cmp_type type');

# Clean up and close the file
ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
