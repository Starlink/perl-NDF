#!perl -w

use Test::More tests => 9;
use strict;
use_ok( "NDF" );

# ================================================================
#   Test MSG calls
#
# ================================================================

# initialise global status
my $good = &NDF::SAI__OK;
my $status = $good;

err_begin($status);

# Make a bell
msg_bell($status);

# Print a blank line
msg_blank($status);

# Set the message level (ADAM only)
msg_ifset(&NDF::MSG__VERB, $status);

msg_setc('TEST', 'This is a test of MSG');

# Test formatting

# Set up some tokens and then return the message

# The keys are the actual msg_set? (set) commands
# The value is the value to set the token
my %tokens = (
	      c => "hello",
	      d => 3.141592654,
              i => -52,
	      r => 162.54,
	      l => 1,
	     );
# The expected result from the token expansion (sometimes different)
my %tokans = (
	      c => "hello",
	      d => 3.141592654,
	      i => -52,
	      r => 162.54,
	      l => "TRUE",
	     );

foreach my $tok (keys %tokens) {
  eval "msg_set$tok('$tok', '$tokens{$tok}');";
  die "Error processing msg_set$tok : $@" if $@;
  msg_load($tok, "^$tok", my $opstr, my $oplen, $status);
  is($opstr, $tokans{$tok}, "Compare tokens");
}

# Now try the formatted equivalent
# Specify yhre format
my %tokfmt = (
	      c => "a10",
	      d => 'F4.2',   # 3.141592654 => 3.14
              i => 'I5.4',
	      r => 'E10.3E3',
	      l => 'I3',
	     );

%tokans = (
	   c => '     hello',
	   d => '3.14',
	   i => '-0052',
	   r => '0.163E+003',
	   l => '  1',
	  );

# On digital unix the formatting of a logical with I3
# actually returns ' -1' rather than '  1'
$tokans{l} = ' -1' if $^O eq 'dec_osf';


# Tuning
msg_tune('SZOUT', 23, $status);
msg_tune('SZOUT', 0, $status);
is($status, $good, "Check status");

# get the message level
my $iflev = msg_iflev( my $as_string, $status );
is($iflev, &NDF::MSG__VERB, "Check level integer");
is($as_string, "VERBOSE", "Check level string");

err_end($status);
