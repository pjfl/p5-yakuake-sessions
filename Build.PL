# @(#)Ident: Build.PL 2013-06-22 15:33 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Yakuake::Sessions),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'             => 5.01,
      'namespace::sweep' => 0.006,
      'Class::Usul'      => q(0.21.0),
      'File::DataClass'  => q(0.20.0),
      'Moo'              => 1.002,
      'MooX::Options'    => 3.83, },
   recommends            => {
      'App::cpanminus'   => 1.6005, },
   configure_requires    => {
      'version'          => 0.88,
      'Module::Build'    => 0.4004, },
   build_requires        => {
      'version'          => 0.88,
      'Module::Build'    => 0.4004, },
   no_index_dir          => [ qw(bin examples inc share t) ],
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# eval: (load-project-state "yakuake-sessions")
# tab-title: Sessions
# tab-width: 3
# End:
