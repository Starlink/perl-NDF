use strict;
use warnings;
use File::Spec;
use ExtUtils::F77;
use ExtUtils::Constant qw/ WriteConstants /;
use Module::Build;
use vars qw/ %StarConfig /;

# Try looking up the config system
eval "use Starlink::Config qw/ :override :verbose/;";
if ($@) {
  print "Could not find Starlink::Config - using /star\n";
  %StarConfig = (
                 Star_Inc => '/star/include',
                 Star_Lib => '/star/lib',
                );
}

# This is the list of libraries required to use the NDF module
# Note that we use a lot of libraries and not just NDF
my $ndflibs = qx/ndg_link/;
$ndflibs .= qx/ one_link/;

die "No NDF libraries were found.\n This may imply that the ndf_link command is not in your path." if $ndflibs !~ /./;

# Fortran libraries depends on the architecture
# Use the ExtUtils::F77 module for this

my $fortranlibs = ExtUtils::F77->runtime;

# CNF libs to handle older CNF builds

my $cnf_defines = '';
my $cnfrtllibs = qx/ cnfrtl_link /;
if (!$cnfrtllibs) {
  $cnf_defines = "-DHAVE_OLD_CNF";
} else {
  $ndflibs .= " ". $cnfrtllibs;
}

WriteConstants(
               NAME => "NDF",
               DEFAULT_TYPE => "IV",
               NAMES => [
                         # These are all enums so we need to tell the routine
                         # not to look use #ifdef
                         { name => "DAT__MXDIM", macro => 1 },
                         { name => "DAT__NOWLD", macro => 1 },
                         { name => "DAT__SZGRP", macro => 1 },
                         { name => "DAT__SZLOC", macro => 1 },
                         { name => "DAT__SZMOD", macro => 1 },
                         { name => "DAT__SZNAM", macro => 1 },
                         { name => "DAT__SZTYP", macro => 1 },
                         { name => "EMS__OPTER", macro => 1 },
                         { name => "EMS__NOMSG", macro => 1 },
                         { name => "EMS__UNSET", macro => 1 },
                         { name => "EMS__BADOK", macro => 1 },
                         { name => "EMS__NSTER", macro => 1 },
                         { name => "EMS__BDKEY", macro => 1 },
                         { name => "EMS__BTUNE", macro => 1 },
                         { name => "EMS__NOENV", macro => 1 },
                         { name => "EMS__EROVF", macro => 1 },
                         { name => "EMS__CXOVF", macro => 1 },
                         { name => "ERR__OPTER", macro => 1 },
                         { name => "ERR__UNSET", macro => 1 },
                         { name => "ERR__BADOK", macro => 1 },
                         { name => "MSG__NORM", macro => 1 },
                         { name => "MSG__QUIET", macro => 1 },
                         { name => "MSG__SZMSG", macro => 1 },
                         { name => "MSG__VERB", macro => 1 },
                         { name => "NDF__SZHIS", macro => 1 },
                         { name => "NDF__SZHMX", macro => 1 },
                         { name => "SAI__OK", macro => 1 },
                         { name => "SAI__WARN", macro => 1 },
                         { name => "SAI__ERROR", macro => 1 },
                        ]);

my $file = File::Spec->catfile( "lib", "NDF.pm" );
my $build = Module::Build->new
  (
   module_name => "NDF",
   abstract_from => $file,
   license => "gpl",
   author => [
              'Tim Jenness <tjenness@cpan.org>',
             ],
   version_from => $file,
   meta_merge => {
               resources =>  {
                              repository => "git://starlink.jach.hawaii.edu/perl-NDF.git",
                             },
                },
   build_requires => {
                      "Test::More" => 0,
                      "Test::Number::Delta" => 0,
                      "ExtUtils::F77" => 0,
                     },
   c_source => "src",
   configure_requires => {
                          "Module::Build" => '0.20',
                          "ExtUtils::F77" => 0,
                         },
   extra_compiler_flags => [ "-I$StarConfig{Star_Inc}", ( $cnf_defines ? $cnf_defines : ()) ],
   extra_linker_flags => "-L$StarConfig{Star_Lib} -Wl,-rpath,$StarConfig{Star_Lib} $ndflibs $fortranlibs",
  );

$build->create_build_script;

