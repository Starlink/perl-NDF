#!perl -w

use Test::More tests => 22;

use warnings;
use strict;

use_ok( "NDF" );

# ================================================================
#   Test HDS calls
#   This is hds_test.f converted to perl
# ================================================================

# initialise global status
my $status = &NDF::SAI__OK;
err_begin( $status );

# Initialise the dimension array
my @dim = (10,20);

# Create a new container file

hds_new('hds_test', 'HDS_TEST', 'NDF', 0, \@dim, my $loc, $status);
is( $status, &NDF::SAI__OK, "check status");

dat_new($loc, 'DATA_ARRAY', '_INTEGER', 2, \@dim, $status);
is( $status, &NDF::SAI__OK, "check status");

# Find and map the data array
dat_find($loc, 'DATA_ARRAY', my $nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_mapv($nloc, '_REAL', 'WRITE', my $pntr, my $el, $status);
is( $status, &NDF::SAI__OK, "check status");

# Make an array
my @data=();
foreach (1..$el) {
  push(@data,$_);
}

if ($status == &NDF::SAI__OK) {
  array2mem(\@data, "f*", $pntr);
}

# Try tracing the locator
hds_trace($nloc, my $trace_nlev, my $trace_path, my $trace_file, $status);
is( $status, &NDF::SAI__OK, "check status after trace");
is( $trace_nlev, 2, 'hds_trace nlev');
is( $trace_path, 'HDS_TEST.DATA_ARRAY', 'hds_trace path');
is( $trace_file, 'hds_test.sdf', 'hds_trace file');

# Clean up and close the file
dat_unmap($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_annul($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");

# Annul the last locator via a group
hds_link($loc, 'MYGROUP', $status);
is( $status, &NDF::SAI__OK, "check status after link");
hds_group($loc, my $group_name, $status);
is( $status, &NDF::SAI__OK, "check status after group");
is( $group_name, 'MYGROUP', 'hds_group name');
hds_flush('MYGROUP', $status);
is( $status, &NDF::SAI__OK, "check status after flush");

# Re-open the file

hds_open('hds_test', 'UPDATE', $loc, $status);
is( $status, &NDF::SAI__OK, "check status");

# Find and map the data array
dat_find($loc, 'DATA_ARRAY', $nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_mapv($nloc, '_INTEGER', 'READ', $pntr, $el, $status);
is( $status, &NDF::SAI__OK, "check status");

# Sum the elements
if ($status == &NDF::SAI__OK) {
  @data = mem2array($pntr, "i*", $el);
}

my $sum = 0;
for ( @data) { $sum += $_; }
is( $sum, 20100, "Check sum");

# Clean up and close the file
dat_unmap($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_annul($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
hds_erase($loc, $status);
is( $status, &NDF::SAI__OK, "check status");

err_end($status);
