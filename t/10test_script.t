# @(#)Ident: 10test_script.t 2013-12-13 14:08 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 3 $ =~ /\d+/gmx );
use File::Spec::Functions   qw( catdir updir );
use FindBin                 qw( $Bin );
use lib                 catdir( $Bin, updir, 'lib' );

use Test::More;
use Test::Requires { version => 0.88 };
use Module::Build;

my $notes = {}; my $perl_ver;

BEGIN {
   my $builder = eval { Module::Build->current };
      $builder and $notes = $builder->notes;
      $perl_ver = $notes->{min_perl_version} || 5.008;
}

use Test::Requires "${perl_ver}";

use_ok 'Yakuake::Sessions';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
