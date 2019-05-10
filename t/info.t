#!perl -w

use Test::More tests => 63;
use strict;

use_ok('NDF');

# Test file
my $file = 'test';

# initialise global status
my $status = &NDF::SAI__OK;

# Initialise NDF
err_begin($status);
ndf_begin();

ndf_gtune('AUTO_HISTORY', my $autohistory, $status);
is($autohistory, 0, 'ndf_gtune');
ndf_tune('AUTO_HISTORY', 1, $status);
ndf_gtune('AUTO_HISTORY', $autohistory, $status);
is($autohistory, 1, 'ndf_gtune');
ndf_tune('AUTO_HISTORY', 0, $status);
ndf_gtune('AUTO_HISTORY', $autohistory, $status);
is($autohistory, 0, 'ndf_gtune');

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

ndf_aclen($indf, 'LABEL', 1, my $axis1_label_length, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_aclen");
is( $axis1_label_length, 7, 'ndf_aclen length');

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

my $bad;
ndf_bad($indf, 'DATA', 0, $bad, $status);
is($bad, 1, 'Check ndf_bad output without check');
ndf_bad($indf, 'DATA', 1, $bad, $status);
is($bad, 0, 'Check ndf_bad output with check');

ndf_bb($indf, my $bb, $status);
is($bb, 0, 'Check ndf_bb');

my (@lbnd, @ubnd);
ndf_bound($indf, 7, \@lbnd, \@ubnd, my $ndim, $status);
is($ndim, 1, 'ndf_bound ndim');
is_deeply(\@lbnd, [1], 'ndf_bound lbnd');
is_deeply(\@ubnd, [10], 'ndf_bound ubnd');

ndf_block($indf, 1, [5], 1, my $indf2, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_block");

ndf_bound($indf2, 7, \@lbnd, \@ubnd, $ndim, $status);
is($ndim, 1, 'ndf_block ndf_bound ndim');
is_deeply(\@lbnd, [1], 'ndf_block ndf_bound lbnd');
is_deeply(\@ubnd, [5], 'ndf_block ndf_bound ubnd');

ndf_annul($indf2, $status);

ndf_chunk($indf, 4, 1, my $indf3, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_chunk");

ndf_bound($indf3, 7, \@lbnd, \@ubnd, $ndim, $status);
is($ndim, 1, 'ndf_chunk ndf_bound ndim');
is_deeply(\@lbnd, [1], 'ndf_chunk ndf_bound lbnd');
is_deeply(\@ubnd, [4], 'ndf_chunk ndf_bound ubnd');

ndf_mbad(1, $indf, $indf3, 'DATA', 0, my $mbad, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_mbad");
is( $mbad, 1, 'ndf_mbad');

ndf_mbadn(1, 2, [$indf, $indf3], 'DATA', 1, my $mbadn, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_mbad");
is( $mbadn, 0, 'ndf_mbad');

ndf_clone($indf, my $indf_clone, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_clone");
ndf_mbnd('PAD', $indf_clone, $indf3, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_mbnd");

ndf_clone($indf, my $indf_clone2, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_clone");
my @ndfs = ($indf_clone2, $indf3, 12345);
ndf_mbndn('PAD', 2, \@ndfs, $status);
($indf_clone2, $indf3) = @ndfs;
is( $status, &NDF::SAI__OK, "check status after ndf_mbndn");

ndf_same($indf, $indf3, my $same, my $isect, $status);
is($same, 1, 'ndf_same same');
is($isect, 1, 'ndf_same isect');

ndf_sbnd(1, [2], [3], $indf3, $status);
ndf_bound($indf3, 7, \@lbnd, \@ubnd, $ndim, $status);
is($ndim, 1, 'ndf_bound ndim');
is_deeply(\@lbnd, [2], 'ndf_bound lbnd');
is_deeply(\@ubnd, [3], 'ndf_bound ubnd');

ndf_annul($indf_clone2, $status);
ndf_annul($indf_clone, $status);
ndf_annul($indf3, $status);

ndf_sect($indf, 1, [6], [8], my $indfsect, $status);
is($status, &NDF::SAI__OK, 'Check status after ndf_sect');
ndf_bound($indfsect, 7, \@lbnd, \@ubnd, $ndim, $status);
is($ndim, 1, 'ndf_bound ndim');
is_deeply(\@lbnd, [6], 'ndf_bound lbnd');
is_deeply(\@ubnd, [8], 'ndf_bound ubnd');
ndf_annul($indfsect, $status);

ndf_clen($indf, 'LABEL', my $clen, $status);
is($clen, 20, 'ndf_clen');

ndf_cmplx($indf, 'DATA', my $cmplx, $status);
is($cmplx, 0, 'ndf_complx');

ndf_isacc($indf, 'WRITE', my $isacc, $status);
is($isacc, 0, 'ndf_isacc');

ndf_isbas($indf, my $isbas, $status);
is($isbas, 1, 'ndf_isbas');

ndf_istmp($indf, my $istmp, $status);
is($istmp, 0, 'ndf_istmp');

ndf_nbloc($indf, 1, [5], my $nbloc, $status);
is($nbloc, 2, 'ndf_nbloc');

ndf_nchnk($indf, 5, my $nchunk, $status);
is($nchunk, 2, 'ndf_nchnk');

ndf_qmf($indf, my $qmf, $status);
is($qmf, 1, 'ndf_qmf');

ndf_size($indf, my $size, $status);
is($size, 10, 'ndf_size');

ndf_valid($indf, my $valid, $status);
is($valid, 1, 'ndf_valid');

ndf_base($indf, my $indfb, $status);
is($status, &NDF::SAI__OK, 'Check status after ndf_base');

# Clean up and close the file
ndf_annul($indf, $status);
ndf_valid($indf, $valid, $status);
is($valid, 0, 'ndf_valid after annul');

ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status');
err_end($status);
