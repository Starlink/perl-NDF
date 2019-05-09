#!perl -w

use Test::More tests => 21;
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

cmp_len($xloc, 'T_TEL', my $cmp_len, $status);
is($cmp_len, 4, 'cmp_len');

cmp_prim($xloc, 'T_COLD', my $cmp_prim, $status);
is($cmp_prim, 1, 'cmp_prim');

cmp_struc($xloc, 'T_AMB', my $cmp_struc, $status);
is($cmp_struc, 0, 'cmp_struc');

dat_annul($xloc, $status);

# Test cmpGet1C and cmpGetVC.
ndf_loc($indf, 'READ', my $hdsloc, $status);
is($status, &NDF::SAI__OK, 'Check status after loc');
dat_find($hdsloc, 'MORE', my $moreloc, $status);
my @fits;
cmp_get1c($moreloc, 'FITS', 200, \@fits, my $nfits, $status);
is($status, &NDF::SAI__OK, 'Check status after cmp_get1c');
is($nfits, 129, 'cmp_get1c el');
is($fits[0], "ACCEPT  = 'PROMPT  '           / accept update; PROMPT, YES or NO", 'cmp_get1c value[0]');
is($fits[128], "END", 'cmp_get1c value[128]');

my @vfits;
cmp_getvc($moreloc, 'FITS', 200, \@vfits, my $nvfits, $status);
is($status, &NDF::SAI__OK, 'Check status after cmp_getvc');
is($nvfits, 129, 'cmp_getvc el');
is($vfits[0], "ACCEPT  = 'PROMPT  '           / accept update; PROMPT, YES or NO", 'cmp_getvc value[0]');
is($vfits[128], "END", 'cmp_getvc value[128]');

# Test cmpShape
my @dim = ();
cmp_shape($xloc, 'DATA_ARRAY', 7, \@dim, my $ndim, $status);
is($ndim, 1, 'cmp_shape ndim');
is($dim[0], 10, 'cmp_shape dim[0]');

cmp_size($xloc, 'DATA_ARRAY', my $size, $status);
is($size, 10, 'cmp_size');

dat_annul($moreloc, $status);
dat_annul($hdsloc, $status);

# Clean up and close the file
ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
