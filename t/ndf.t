#!perl -w

use Test::More tests => 26;
use strict;

use_ok("NDF");

# ================================================================
#   Test NDF calls
#    - NDF version of hds.t
# ================================================================

# initialise global status
my $status = &NDF::SAI__OK;

# Initialise the dimension array
my @ubnd = (10,20);
my @lbnd = (1,1);


# Initialise NDF
err_begin($status);
ndf_begin();

# Create a new container file
ndf_place(&NDF::DAT__ROOT, 'ndf_test', my $place, $status);
is( $status, &NDF::SAI__OK, "check status ndf_place");

ndf_new('_INTEGER', 2, \@lbnd, \@ubnd, $place, my $indf, $status);
is( $status, &NDF::SAI__OK, "check status ndf_new");

ndf_acre($indf, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_acre");

ndf_acput('ELEPHANTS', $indf, 'UNITS', 1, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_acput");

my $axis1_units = '';
ndf_acget($indf, 'UNITS', 1, $axis1_units, $status);
is( $axis1_units, 'ELEPHANTS', 'ndf_acget');

my $axis1_state;
ndf_astat($indf, 'UNITS', 1, $axis1_state, $status);
is($axis1_state, 1, 'Axis 1 state after assignment');

ndf_arest($indf, 'UNITS', 1, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_arest");

ndf_astat($indf, 'UNITS', 1, $axis1_state, $status);
is($axis1_state, 0, 'Axis 1 state after reset');

my $axis1_norm = undef;
ndf_anorm($indf, 1, $axis1_norm, $status);
is($axis1_norm, 0, 'Check axis 1 normalization');

ndf_asnrm(1, $indf, 1, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_asnrm");

ndf_anorm($indf, 1, $axis1_norm, $status);
is($axis1_norm, 1, 'Check axis 1 normalization after update');

ndf_astyp('_DOUBLE', $indf, 'CENTRE', 1, $status);
is( $status, &NDF::SAI__OK, "check status after ndf_astyp");

ndf_amap($indf, 'CENTRE', 1, '_DOUBLE', 'READ', my $axpntr, my $axel, $status);
is( $status, &NDF::SAI__OK, "check status ndf_amap");

ndf_aunmp($indf, 'CENTRE', 1, $status);
is( $status, &NDF::SAI__OK, "check status ndf_aunmp");

ndf_cput('HEFFALUMPS', $indf, 'UNITS', $status);
is( $status, &NDF::SAI__OK, "check status ndf_cput");
my $units= '';
ndf_cget($indf, 'UNITS', $units, $status);
is($units, 'HEFFALUMPS', 'Check NDF units');

# Map the data array
ndf_map($indf, 'DATA', '_INTEGER', 'WRITE', my $pntr, my $el, $status);
is( $status, &NDF::SAI__OK, "check status ndf_map");

# Make an array
my @data=();
foreach (1..$el) {
  push(@data,$_);
}

array2mem(\@data, "i*", $pntr) if ($status == &NDF::SAI__OK);

# Clean up and close the file
ndf_unmap($indf, 'DATA',  $status);
is( $status, &NDF::SAI__OK, "check status ndf_unmap");
ndf_annul($indf, $status);
is( $status, &NDF::SAI__OK, "check status ndf_annul");

# Re-open the file

ndf_find(&NDF::DAT__ROOT,'ndf_test',$indf, $status);
is( $status, &NDF::SAI__OK, "check status ndf_find");

# Check the dimensions
my $maxdims = 100;
my @dim;
my $ndim;
ndf_dim($indf, $maxdims, \@dim, $ndim, $status);
is( $status, &NDF::SAI__OK, "check status ndf_dim");

print "# Dims are: ", join(" ",@dim), " [$ndim dimensions]\n";

# Find and map the data array
ndf_map($indf, 'DATA', '_INTEGER', 'READ', $pntr, $el, $status);
is( $status, &NDF::SAI__OK, "check status ndf_map");

# Sum the elements
@data = mem2array($pntr, "i*", $el) if ($status == &NDF::SAI__OK);

my $sum = 0;
for ( @data) { $sum += $_; }
is( $sum, 20100, "Check sum");

# Clean up and close the file
ndf_unmap($indf, 'DATA', $status);
is( $status, &NDF::SAI__OK, "check status ndf_unmap");
ndf_annul($indf, $status);
ndf_end($status);

unlink("ndf_test.sdf");

is( $status, &NDF::SAI__OK, "check status");
err_end($status);
