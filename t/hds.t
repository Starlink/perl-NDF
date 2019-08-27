#!perl -w

use Test::More tests => 78;

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

dat_prmry(0, $loc, my $primary = 2, $status);
is( $status, &NDF::SAI__OK, "check status after dat_prmry");
is( $primary, 1, 'dat_prmry');

dat_refct($loc, my $refct, $status);
is( $status, &NDF::SAI__OK, "check status after dat_refct");
is( $refct, 1, 'dat_refct');

dat_new($loc, 'DATA_ARRAY', '_INTEGER', 2, \@dim, $status);
is( $status, &NDF::SAI__OK, "check status");

# Find and map the data array
dat_find($loc, 'DATA_ARRAY', my $nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_mapv($nloc, '_REAL', 'WRITE', my $pntr, my $el, $status);
is( $status, &NDF::SAI__OK, "check status");

dat_prmry(0, $nloc, $primary, $status);
is( $status, &NDF::SAI__OK, "check status after dat_prmry");
is( $primary, 0, 'dat_prmry');

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

# Clean up
dat_unmap($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");
dat_annul($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");

# Try working with string arrays
dat_new1c($loc, 'STRTEST', 10, 3, $status);
is( $status, &NDF::SAI__OK, "check status after dat_new1c");
dat_find($loc, 'STRTEST', my $strloc, $status);

dat_put1c($strloc, 3, [qw/One Two Three/], $status);
is( $status, &NDF::SAI__OK, "check status after dat_put1c");
dat_annul($strloc, $status);

dat_new($loc, 'STRARR', '_CHAR*10', 2, [2, 2], $status);
is( $status, &NDF::SAI__OK, "check status after dat_new _CHAR*10");
dat_find($loc, 'STRARR', $strloc, $status);
dat_putvc($strloc, 4, [qw/Alpha Beta Gamma Delta/], $status);
is( $status, &NDF::SAI__OK, "check status after dat_putvc");

dat_annul($strloc, $status);

dat_new1c($loc, 'ADDR', 10, 3, $status);
cmp_put1c($loc, 'ADDR', 3, [qw/West Wallaby Street/], $status);
is( $status, &NDF::SAI__OK, "check status after cmp_put1c");

dat_new($loc, 'STRARR2', '_CHAR*10', 2, [2, 2], $status);
cmp_putvc($loc, 'STRARR2', 4, [qw/X Y Z W/], $status);
is( $status, &NDF::SAI__OK, "check status after cmp_putvc");

dat_new($loc, 'STRARR3', '_CHAR*5', 1, [2], $status);
dat_find($loc, 'STRARR3', $strloc, $status);
dat_putc($strloc, 1, [2], ['Aaaaa', 'B'], $status);
is( $status, &NDF::SAI__OK, "check status after dat_putc");
dat_annul($strloc, $status);

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

dat_unmap($nloc, $status);
is( $status, &NDF::SAI__OK, "check status");

# Try using cmpMapV to map the array
cmp_mapv($loc, 'DATA_ARRAY', '_INTEGER', 'READ', $pntr, $el, $status);
is( $status, &NDF::SAI__OK, "check status after cmp_mapv");
is( $el, 200, "cmp_mapv el");

if ($status == &NDF::SAI__OK) {
  @data = mem2array($pntr, "i*", $el);
  is_deeply( \@data, [1 .. 200], "cmp_mapv data");
}
else {
  fail 'could not compare cmp_mapv data';
}

cmp_unmap($loc, 'DATA_ARRAY', $status);
is( $status, &NDF::SAI__OK, "check status after cmp_unmap");

my @shapedim = ();
dat_shape($nloc, 7, \@shapedim, my $ndim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_shape");
is( $ndim, 2, "dat_shape ndim");
is( $shapedim[0], 10, 'dat_shape dim[0]');
is( $shapedim[1], 20, 'dat_shape dim[1]');

@dim = (10, 200);
dat_alter($nloc, 2, \@dim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_alter");
dat_shape($nloc, 7, \@shapedim, $ndim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_shape (2)");
is( $ndim, 2, "dat_shape ndim (2)");
is( $shapedim[0], 10, 'dat_shape dim[0] (2)');
is( $shapedim[1], 200, 'dat_shape dim[1] (2)');

dat_new($loc, 'MYSTRUCT', 'TEST', 0, [0], $status);
is( $status, &NDF::SAI__OK, "check status after dat_new");
dat_find($loc, 'MYSTRUCT', my $sloc, $status);
is( $status, &NDF::SAI__OK, "check status after dat_find");
dat_name($sloc, my $slocname, $status);
is( $slocname, 'MYSTRUCT', 'dat_new dat_name');
dat_ccopy($nloc, $sloc, 'COPY', my $cloc, $status);
is( $status, &NDF::SAI__OK, "check status after dat_ccopy");
dat_name($cloc, my $copyname, $status);
is( $copyname, 'COPY', 'dat_ccopy loc3 name');
dat_paren($cloc, my $pcloc, $status);
dat_name($pcloc, my $parentcopyname, $status);
is( $parentcopyname, 'MYSTRUCT', 'dat_ccopy loc3 parent name');

dat_annul($pcloc, $status);
dat_annul($cloc, $status);

dat_copy($nloc, $sloc, 'COPY2', $status);
is( $status, &NDF::SAI__OK, "check status after dat_copy");
dat_find($sloc, 'COPY2', my $c2loc, $status);
is( $status, &NDF::SAI__OK, "check status after dat_copy dat_find");
dat_name($c2loc, my $copy2name, $status);
is( $copy2name, 'COPY2', 'dat_copy dat_name');

dat_renam($c2loc, 'COPY3', $status);
is( $status, &NDF::SAI__OK, "check status after dat_renam");
dat_annul($c2loc, $status);

dat_erase($sloc, 'COPY3', $status);
is( $status, &NDF::SAI__OK, "check status after dat_erase");

# Test datMove. (Note this annuls $nloc.)
dat_move($nloc, $sloc, 'MOVED', $status);
is( $status, &NDF::SAI__OK, "check status after dat_move");
dat_find($sloc, 'MOVED', my $movedloc, $status);
is( $status, &NDF::SAI__OK, "check status after dat_move dat_find");

dat_annul($sloc, $status);
is( $status, &NDF::SAI__OK, "check status");

# Check the values in the string array
my @str = ();
cmp_get1c($loc, 'STRTEST', 10, \@str, my $nstr, $status);
is( $status, &NDF::SAI__OK, "check status after cmp_get1c");
is( $nstr, 3, 'cmp_get1c el');
is( $str[0], 'One', 'cmp_get1c value[0]');
is( $str[1], 'Two', 'cmp_get1c value[1]');
is( $str[2], 'Three', 'cmp_get1c value[2]');

cmp_getvc($loc, 'STRARR', 10, \@str, $nstr, $status);
is( $status, &NDF::SAI__OK, "check status after cmp_getvc");
is( $nstr, 4, 'cmp_getvc nstr');
is( $str[0], 'Alpha', 'cmp_getvc value[0]');
is( $str[1], 'Beta', 'cmp_getvc value[1]');
is( $str[2], 'Gamma', 'cmp_getvc value[2]');
is( $str[3], 'Delta', 'cmp_getvc value[3]');

cmp_getvc($loc, 'ADDR', 10, \@str, $nstr, $status);
is( $nstr, 3, 'cmp_getvc nstr');
is_deeply([@str[0..2]], [qw/West Wallaby Street/], 'cmp_getvc str');

cmp_getvc($loc, 'STRARR2', 10, \@str, $nstr, $status);
is( $nstr, 4, 'cmp_getvc nstr');
is_deeply(\@str, [qw/X Y Z W/], 'cmp_getvc str');

cmp_get1c($loc, 'STRARR3', 10, \@str, $nstr, $status);
is( $nstr, 2, 'cmp_get1c nstr');
is_deeply([@str[0..1]], [qw/Aaaaa B/], 'cmp_get1c str');

# Clean up and close the file
hds_erase($loc, $status);
is( $status, &NDF::SAI__OK, "check status");

err_end($status);
