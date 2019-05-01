#!perl -w

use Test::More tests => 20;
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

dat_cctyp(16, my $ctype);
is($ctype, '_CHAR*16', 'dat_cctyp');

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
dat_annul($loc, $status);

# Test datRef
dat_ref($xloc, my $ref, my $lref, $status);
ok($ref =~ /test.MORE.REDS$/, 'dat_ref ref');
is($lref, length($ref), 'dat_ref reflen');

# Test datType
dat_type($xloc, my $type, $status);
is($type, 'SCUBA_REDS', 'dat_type');

dat_annul($xloc, $status);

# Test datGetVC
ndf_xloc($indf, 'FITS', 'READ', my $xloc, $status);
is($status, &NDF::SAI__OK, 'Check status after xloc FITS');

my (@fits, $nfits);
dat_getvc($xloc, 200, \@fits, $nfits, $status);
is($status, &NDF::SAI__OK, 'Check status after dat_getvc');
is($nfits, 129, 'dat_getvc el');
is($fits[0], "ACCEPT  = 'PROMPT  '           / accept update; PROMPT, YES or NO", 'dat_getvc value[0]');
is($fits[128], "END", 'dat_getvc value[128]');

dat_annul($xloc, $status);

ndf_annul($indf, $status);
ndf_end($status);
is($status, &NDF::SAI__OK, 'Check status at end');
err_end($status);
