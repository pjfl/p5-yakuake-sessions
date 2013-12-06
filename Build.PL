# @(#)$Ident: Build.PL 2013-12-06 14:50 pjf ;

use strict;
use warnings;

use Module::Build ##{ $meta2{prereqs}->{configure}->{requires}->{'Module::Build'} ##};

sub whimper { print {*STDOUT} $_[ 0 ]."\n"; exit 0 }

my $perl_ver = ##{ $meta2{prereqs}->{runtime}->{requires}->{perl} ##};
my $name     = '##{ $zilla->name ##}'; $name =~ s{ - }{::}gmx;

$] >= $perl_ver or $ENV{PERL5_CPANPLUS_IS_VERSION}
   or whimper "Minimum required Perl version is ${perl_ver}";

Module::Build->new(
  'module_name' => $name,
  'notes'       => { min_perl_version => $perl_ver },
##{ $plugin->get_prereqs( 1 ) ##}
##{ $plugin->get_default('share_dir') ##}
)->create_build_script;

exit 0;
