#!perl -w

use Test::More tests => 13;
use Test::Number::Delta;
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
is($status, &NDF::SAI__OK, 'Check status on opening file');

ndf_xiary($indf, 'TESTEXT', 'TESTARRAY.DATA_ARRAY', 'READ', my $iary, $status);
is($status, &NDF::SAI__OK, 'Check status after ndf_xiary');

isa_ok($iary, 'AryPtr');

my @dim = ();
ary_dim($iary, 7, \@dim, my $ndim, $status);
is($status, &NDF::SAI__OK, 'Check status after ary_dim');
is($ndim, 1, 'ary_dim ndim');
is($dim[0], 10, 'ary_dim dim[0]');

ary_map($iary, '_REAL', 'READ', my $pntr, my $el, $status);
is($status, &NDF::SAI__OK, 'Check status after ary_map');
is($el, 10, 'ary_map el');

my @data = mem2array($pntr, 'f*', $el);
is_deeply(\@data, [(123) x 10], 'ary_map data');

ary_unmap($iary, $status);
is($status, &NDF::SAI__OK, 'Check status after ary_unmap');

ary_annul($iary, $status);
is($status, &NDF::SAI__OK, 'Check status after ary_annul');

ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
