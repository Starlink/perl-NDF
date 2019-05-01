#!perl -w

use Test::More tests => 15;
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

my $axis1_label = '';
ndf_acget($indf, 'LABEL', 1, $axis1_label, $status);
is($axis1_label, 'AIRMASS', 'Check axis 1 label');

my $axis1_form = '';
ndf_aform($indf, 'CENTRE', 1, $axis1_form, $status);
is($axis1_form, 'PRIMITIVE', 'Check axis 1 centre form');

my $axis1_type = '';
ndf_atype($indf, 'CENTRE', 1, $axis1_type, $status);
is($axis1_type, '_REAL', 'Check axis 1 centre type');

my $title = '';
ndf_cget($indf, 'TITLE', $title, $status);
is($title, 'Skydip', 'Check NDF title');

my $form = '';
ndf_form($indf, 'DATA', $form, $status);
is($form, 'PRIMITIVE', 'Check NDF form');

my $type = '';
ndf_type($indf, 'DATA', $type, $status);
is($type, '_REAL', 'Check NDF type');

my $ftype = '';
ndf_ftype($indf, 'DATA', $ftype, $status);
is($ftype, '_REAL', 'Check NDF full type');

my $itype = '';
my $dtype = '';
ndf_mtype('_INTEGER,_DOUBLE', $indf, $indf, 'DATA', $itype, $dtype, $status);
is($itype, '_DOUBLE', 'Match NDF type for processing');
is($dtype, '_REAL', 'Match NDF type for storage');

ndf_mtypn('_INTEGER,_DOUBLE', 1, [$indf], 'DATA', $itype, $dtype, $status);
is($itype, '_DOUBLE', 'Match NDF list type for processing');
is($dtype, '_REAL', 'Match NDF list type for storage');

my $xname = '';
ndf_xname($indf, 1, $xname, $status);
is($xname, 'FIGARO', 'Check first extension name');

# Clean up and close the file
ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status');
err_end($status);
