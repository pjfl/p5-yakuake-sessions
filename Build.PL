# @(#)Ident: Build.PL 2013-04-25 03:04 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Yakuake::Sessions),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'             => 5.010,
      'version'          => 0.77,
      'Class::Usul'      => q(0.14.0),
      'File::DataClass'  => q(0.16.0), },
   recommends            => {
      'App::cpanminus'   => 1.6005,
      'Pod::Markdown'    => 1.322, },
   configure_requires    => {
      'version'          => 0.77,
      'Module::Build'    => 0.38, },
   build_requires        => {
      'Exception::Class' => 1.23,
      'Test::More'       => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# eval: (load-project-state "yakuake-sessions")
# tab-title: Sessions
# tab-width: 3
# End:
