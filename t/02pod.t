# @(#)Ident: 02pod.t 2013-04-22 22:42 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.12.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use English qw(-no_match_vars);
use Test::More;

BEGIN {
   $ENV{AUTHOR_TESTING} or plan skip_all => 'POD test only for developers';
}

eval "use Test::Pod 1.14";

$EVAL_ERROR and plan skip_all => 'Test::Pod 1.14 required';

all_pod_files_ok();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
