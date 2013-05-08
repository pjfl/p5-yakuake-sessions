# @(#)Ident: 06yaml.t 2013-04-22 22:46 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use English qw(-no_match_vars);
use Test::More;

BEGIN {
   $ENV{AUTHOR_TESTING} or plan skip_all => 'YAML test only for developers';
}

eval { require Test::YAML::Meta; };

$EVAL_ERROR and plan skip_all => 'Test::YAML::Meta not installed';

Test::YAML::Meta->import();

meta_yaml_ok();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
