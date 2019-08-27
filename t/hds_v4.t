#!perl -w

use Test::More tests => 14;

use warnings;
use strict;

use_ok( "NDF" );

# Test script for HDS-v4-only functions.

# Initialise global status
my $status = &NDF::SAI__OK;
err_begin( $status );

hds_gtune('VERSION', my $version, $status);
is( $version, 5, 'hds_gtune version');

hds_tune('VERSION', 4, $status);
is( $status, &NDF::SAI__OK, "check status on hds_tune VERSION 4");

hds_gtune('VERSION', $version, $status);
is( $version, 4, 'hds_gtune version');

# Initialise the dimension array
my @dim = (10, 20);

# Create a new container file

hds_new('hds_test', 'HDS_TEST', 'NDF', 0, \@dim, my $loc, $status);
is( $status, &NDF::SAI__OK, "check status");

dat_new($loc, 'DATA_ARRAY', '_INTEGER', 2, \@dim, $status);
is( $status, &NDF::SAI__OK, "check status");

dat_find($loc, 'DATA_ARRAY', my $nloc, $status);

@dim = (20, 10);
dat_mould($nloc, 2, \@dim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_mould");

my @shapedim = ();
dat_shape($nloc, 7, \@shapedim, my $ndim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_shape");
is( $ndim, 2, "dat_shape ndim");
is( $shapedim[0], 20, 'dat_shape dim[0]');
is( $shapedim[1], 10, 'dat_shape dim[1]');

# Clean up and close the file
dat_annul($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
hds_erase($loc, $status);
is( $status, &NDF::SAI__OK, "check status");

hds_tune('VERSION', $version, $status);
is( $status, &NDF::SAI__OK, "check status on hds_tune");
err_end($status);
