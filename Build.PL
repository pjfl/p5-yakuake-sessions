# @(#)Ident: Build.PL 2013-05-11 12:54 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev: 2 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Yakuake::Sessions),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'                  => 5.01,
      'namespace::autoclean'  => 0.13,
      'Class::Usul'           => q(0.19.0),
      'File::DataClass'       => q(0.20.0),
      'Moose'                 => 2.0802,
      'MooseX::Types'         => 0.35,
      'MooseX::Types::Common' => 0.001008, },
   recommends                 => {
      'App::cpanminus'        => 1.6005, },
   configure_requires         => {
      'version'               => 0.88,
      'Module::Build'         => 0.4004, },
   build_requires             => {
      'version'               => 0.88,
      'Module::Build'         => 0.4004, },
   no_index_dir               => [ qw(bin examples inc share t) ],
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# eval: (load-project-state "yakuake-sessions")
# tab-title: Sessions
# tab-width: 3
# End:
