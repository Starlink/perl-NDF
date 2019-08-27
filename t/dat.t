#!perl -w

use Test::More tests => 50;
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

ndf_xloc($indf, 'REDS', 'READ', my $xloc, $status);
is($status, &NDF::SAI__OK, 'Check status after xloc REDS');

dat_prim($xloc, my $reply, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_prim');
is($reply, 0, 'dat_prim (struct)');

dat_struc($xloc, my $sreply, $status);
is($sreply, 1, 'dat_struc (struct)');

dat_ncomp($xloc, my $ncomp, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_ncomp');
is($ncomp, 6, 'dat_ncomp');

dat_cctyp(16, my $ctype);
is($ctype, '_CHAR*16', 'dat_cctyp');

dat_there($xloc, 'T_AMB', my $reply1, $status);
is($reply1, 1, 'dat_there T_AMB');

dat_there($xloc, 'T_SKY', my $reply2, $status);
is($reply2, 0, 'dat_there T_SKY');

# Test datDrep -- requires HDSv4 test file (as HDSv5 does not
# implement datDrep.
dat_find($xloc, 'T_TEL', my $loc, $status);
dat_drep($loc, my $format, my $order, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_drep');
is($format, 'IEEE_S', 'dat_drep format');
is($order, 'MSB', 'dat_drep order');
dat_annul($loc, $status);

# Test datErmsg -- should use constant DAT__LOCIN here.
dat_ermsg(147358499, my $msglen, my $msgtext);
is($msglen, 28, 'dat_ermsg length');
is($msgtext, 'Locator invalid (DAT__LOCIN)', 'dat_errmsg message');

# Test datGet0C
dat_find($xloc, 'FILTER', $loc, $status);
dat_get0c($loc, my $get_filter, $status);
is($get_filter, '850', 'dat_get0c value');

dat_name($loc, my $name, $status);
is($name, 'FILTER', 'dat_name');

dat_prec($loc, my $nbyte, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_prec');
is($nbyte, 15, 'dat_prec');

dat_prim($loc, $reply, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_prim');
is($reply, 1, 'dat_prim (prim)');

dat_struc($loc, $sreply, $status);
is($sreply, 0, 'dat_struc (prim)');

dat_size($loc, my $size, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_size');
is($size, 1, 'dat_size');

dat_annul($loc, $status);

# Test datRef
dat_ref($xloc, my $ref, my $lref, $status);
ok($ref =~ /test.MORE.REDS$/, 'dat_ref ref');
is($lref, length($ref), 'dat_ref reflen');

# Test datType
dat_type($xloc, my $type, $status);
is($type, 'SCUBA_REDS', 'dat_type');

# Test datIndex and datLen
dat_index($xloc, 3, my $indexloc, $status);
dat_name($indexloc, my $indexlocname, $status);
is($indexlocname, 'WAVELENGTH', 'dat_index dat_name');

dat_len($indexloc, my $indexlen, $status);
is($indexlen, 4, 'dat_index dat_len');
dat_annul($indexloc, $status);

dat_annul($xloc, $status);

# Test datGetVC
ndf_xloc($indf, 'FITS', 'READ', $xloc, $status);
is($status, &NDF::SAI__OK, 'Check status after xloc FITS');

my (@fits, $nfits);
dat_getvc($xloc, 200, \@fits, $nfits, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_getvc');
is($nfits, 129, 'dat_getvc el');
is($fits[0], "ACCEPT  = 'PROMPT  '           / accept update; PROMPT, YES or NO", 'dat_getvc value[0]');
is($fits[128], "END", 'dat_getvc value[128]');

# Try accessing the FITS extension with datCell.
dat_cell($xloc, 1, [129], my $cellloc, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_cell');
dat_get0c($cellloc, my $card, $status);
is($card, 'END', 'dat_cell dat_get0c');
dat_clen($cellloc, my $celllen, $status);
is($celllen, 80, 'dat_cell dat_clen');

dat_clone($cellloc, my $cloneloc, $status);
dat_clen($cloneloc, my $clonelen, $status);
is($celllen, 80, 'dat_clone dat_clen');
dat_annul($cloneloc, $status);
dat_annul($cellloc, $status);

dat_annul($xloc, $status);

ndf_loc($indf, 'READ', my $hdsloc, $status);
dat_find($hdsloc, 'TITLE', my $titleloc, $status);
dat_basic($titleloc, 'READ', my $pntr, my $basic_len, $status);
is($basic_len, 6, 'dat_basic len');
my @data;
if ($status == &NDF::SAI__OK) {
  @data = mem2array($pntr, "c*", $basic_len);
}
is_deeply(\@data, [map {ord} split //, qw/Skydip/], 'dat_basic pntr');
dat_unmap($titleloc, $status);

dat_annul($titleloc, $status);

# Test datCoerc -- requires HDSv4 test file.
dat_find($hdsloc, 'DATA_ARRAY', my $dataloc, $status);
dat_coerc($dataloc, 3, my $coercloc, $status);
is( $status, &NDF::SAI__OK, "check status after dat_coerc");
my @shapedim = ();
dat_shape($coercloc, 7, \@shapedim, my $ndim, $status);
is( $status, &NDF::SAI__OK, "check status after dat_shape");
is( $ndim, 3, "dat_shape ndim");
is( $shapedim[0], 10, 'dat_shape dim[0]');
is( $shapedim[1], 1, 'dat_shape dim[1]');
is( $shapedim[2], 1, 'dat_shape dim[2]');
dat_annul($coercloc, $status);

# Test datMap
dat_map($dataloc, '_REAL', 'READ', 1, [10], $pntr, $status);
is( $status, &NDF::SAI__OK, "check status after dat_map");
if ($status == &NDF::SAI__OK) {
  @data = mem2array($pntr, "f*", 10);
}
delta_within( $data[0], 225.4935, 0.0001, 'dat_map data[0]');

dat_annul($dataloc, $status);

dat_msg('TESTTOKEN', $hdsloc);

dat_annul($hdsloc, $status);

ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
