#!perl -w

use Test::More tests => 46;
use warnings;
use strict;
use Test::Number::Delta;

use_ok( "NDF" );

# ================================================================
#   Test NDF calls to write extension information
#   test.sdf
# ================================================================

# Test file
my $oldfile = "test";
my $file = "twrite";

# initialise global status
my $status = &NDF::SAI__OK;

# Initialise NDF
err_begin($status);
ndf_begin();

# Open up the test file
die "Couldn't find test file: $oldfile\n" unless (-e "$oldfile.sdf");

# Copy the reference file for testing purposes
ndf_place( &NDF::DAT__ROOT, $file, my $place, $status );
is( $status, &NDF::SAI__OK, "check status");
ndf_find( &NDF::DAT__ROOT, $oldfile, my $oldndf, $status );
ndf_copy($oldndf, $place, my $indf, $status );
is( $status, &NDF::SAI__OK, "check status");

# Add an extension
my @dim = ();
ndf_xnew($indf, 'TEST', 'PERL_TEST', 0, \@dim, my $loca, $status);
is($status, &NDF::SAI__OK, "Check status");

@dim = (1,2);
ndf_xnew($indf, 'ARY_TEST', 'PERL_TEST_ARR', 2, \@dim, my $locb, $status);
is($status, &NDF::SAI__OK, "Check status");

# Add some data

my $cinval = "hello";
my $dinval = 3.141592654456;
my $iinval = 5;
my $linval = 1;
my $rinval = 26.8;

ndf_xpt0c($cinval, $indf, 'TEST', 'CHAR', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xpt0d($dinval, $indf, 'TEST', 'DBL', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xpt0i($iinval, $indf, 'TEST', 'INT', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xpt0l($linval, $indf, 'TEST', 'LOG', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xpt0r($rinval, $indf, 'TEST', 'REAL', $status);

# Read it back
my $cval = '';
my $dval = 0.0;
my $ival = 0;
my $lval = 0;
my $rval = 0.0;
ndf_xgt0c($indf, 'TEST', 'CHAR', $cval, $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xgt0d($indf, 'TEST', 'DBL', $dval, $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xgt0i($indf, 'TEST', 'INT', $ival, $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xgt0l($indf, 'TEST', 'LOG', $lval, $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xgt0r($indf, 'TEST', 'REAL', $rval, $status);
is($status, &NDF::SAI__OK, "Check status");

# Try to create an NDF in the extension
ndf_xstat( $indf, "TEST", my $there, $status );
ok($there, "Extension is present");
ndf_open( $loca, "MAPCOORD", "WRITE", "UNKNOWN", my $cndf, $place, $status);
is($cndf, 0, "No NDF ID");
isnt($place, 0, "Place holder");

my @lbnd = (1);
my @ubnd = (2);
ndf_new( "_INTEGER", 1, @lbnd, @ubnd, $place, $cndf, $status );
ndf_map( $cndf, "DATA", "_INTEGER", "WRITE", my $pntr, my $el, $status);
ndf_unmap($cndf, 'DATA', $status);

ndf_bad($cndf, 'DATA', 0, my $bad, $status);
ok($bad, 'ndf_bad');
ndf_sbad(0, $cndf, 'DATA', $status);
ndf_bad($cndf, 'DATA', 0, $bad, $status);
is($bad, 0, 'ndf_bad');

ndf_bb($cndf, my $bb, $status);
is($bb, 0, 'Check ndf_bb');
ndf_sbb(10, $cndf, $status);
ndf_bb($cndf, $bb, $status);
is($bb, 10, 'Check ndf_bb');

ndf_qmf($indf, my $qmf, $status);
is($qmf, 1, 'ndf_qmf');
ndf_sqmf(0, $indf, $status);
is($status, &NDF::SAI__OK, "Check status after ndf_sqmf");
ndf_qmf($indf, $qmf, $status);
is($qmf, 0, 'ndf_qmf');

ndf_shift(1, [1000], $cndf, $status);
ndf_bound($cndf, 7, \@lbnd, \@ubnd, my $ndim, $status);
is($ndim, 1, 'ndf_bound ndim');
is_deeply(\@lbnd, [1001], 'ndf_bound lbnd');
is_deeply(\@ubnd, [1002], 'ndf_bound ubnd');

ndf_annul( $cndf, $status );

dat_annul( $loca, $status );
dat_annul( $locb, $status );

# Try also using ndf_newp
ndf_xnew($indf, 'TESTP', 'NDF', 0, [], my $locp, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_xnew");
ndf_place($locp, '', my $placep, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_place");
ndf_newp('_REAL', 2, [5, 5], $placep, my $indfp, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_newp");
ndf_reset($indfp, 'DATA', $status);
ndf_state($indfp, 'DATA', my $state, $status);
is($state, 0, 'ndf_state');
ndf_map($indfp, 'DATA', '_REAL', 'WRITE', $pntr, $el, $status);
ndf_unmap($indfp, 'DATA', $status);
ndf_state($indfp, 'DATA', $state, $status);
is($state, 1, 'ndf_state');
ndf_annul($indfp, $status);
dat_annul($locp, $status);

# delete the extensions
ndf_xdel($indf, 'TESTP', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xdel($indf, 'TEST', $status);
is($status, &NDF::SAI__OK, "Check status");
ndf_xdel($indf, 'ARY_TEST', $status);
is($status, &NDF::SAI__OK, "Check status");

# Try using ndf_noacc
ndf_isacc($indf, 'WRITE', my $isacc, $status);
ok($isacc, 'ndf_isacc');
ndf_noacc('WRITE', $indf, $status);
ndf_isacc($indf, 'WRITE', $isacc, $status);
is($isacc, 0, 'ndf_isacc');

ndf_delet($indf, $status);
is( $status, &NDF::SAI__OK, "check status");
ok( !-e "$file.sdf", "File no longer exists");

ndf_temp(my $tempplace, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_temp");

ndf_end($status);
is($status, &NDF::SAI__OK, "Check status");
err_end($status);

is( $cval, $cinval, "Compare CHAR");
is( $lval, $linval, "Compare LOGICAL");
is( $ival, $iinval, "Compare INTEGER");
delta_ok( $dval, $dinval, "Compare DOUBLE");

# deal with rounding
is( sprintf("%.1f", $rval), $rinval, "Compare REAL");


