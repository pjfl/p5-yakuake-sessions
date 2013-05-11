# @(#)Ident: Bob.pm 2013-05-05 22:54 pjf ;

package Bob;

use strict;
use warnings;
use inc::CPANTesting;

sub whimper { print {*STDOUT} $_[ 0 ]."\n"; exit 0 }

BEGIN { my $reason; $reason = CPANTesting::should_abort and whimper $reason; }

use version; our $VERSION = qv( '1.14' );

use File::Spec::Functions qw(catfile);
use Module::Build;

sub new {
   my ($class, $p) = @_; $p ||= {}; $p->{requires} ||= {};

   my $perl_ver    = $p->{requires}->{perl} || 5.008_008;

   $] < $perl_ver and whimper "Perl minimum ${perl_ver}";

   my $module      = $p->{module} or whimper 'No module name';
   my $distname    = $module; $distname =~ s{ :: }{-}gmx;
   my $class_path  = catfile( q(lib), split m{ :: }mx, $module.q(.pm) );

   return __get_build_class( $p )->new
      ( add_to_cleanup     => __get_cleanup_list( $p, $distname ),
        build_requires     => $p->{build_requires},
        configure_requires => $p->{configure_requires},
        create_license     => 1,
        create_packlist    => 0,
        create_readme      => 1,
        dist_version_from  => $class_path,
        license            => $p->{license} || q(perl),
        meta_merge         => __get_resources( $p, $distname ),
        module_name        => $module,
        no_index           => __get_no_index( $p ),
        notes              => __get_notes( $p ),
        recommends         => $p->{recommends},
        requires           => $p->{requires},
        sign               => defined $p->{sign} ? $p->{sign} : 1,
        share_dir          => __get_share_dir( $p ), );
}

# Private functions

sub __is_src { # Is this the developer authoring a module?
   return -f q(MANIFEST.SKIP);
}

sub __get_build_class { # Which subclass of M::B should we create?
   my $p = shift; exists $p->{build_class} and return $p->{build_class};

   my $path = catfile( qw(inc SubClass.pm) );

   -f $path or return 'Module::Build';

   open my $fh, '<', $path or whimper "File ${path} cannot open: ${!}";

   my $code = do { local $/ = undef; <$fh> }; close $fh;

   return Module::Build->subclass( code => $code );
}

sub __get_cleanup_list {
   my $p = shift; my $distname = shift;

   return [ q(Debian_CPANTS.txt), q(MANIFEST.bak), "${distname}-*",
            map { ( q(*/) x $_ ).q(*~) } 0..5 ];
}

sub __get_git_repository {
   return (map  { s{ : }{/}mx; s{ @ }{://}mx; $_ }
           grep { m{ \A git }mx }
           map  { s{ \s+ }{ }gmx; (split ' ', $_)[ 1 ] }
           grep { m{ \A origin }mx }
           qx{ git remote -v 2>/dev/null })[ 0 ];
}

sub __get_no_index {
   my $p = shift;

   return { directory => $p->{no_index_dir} || [ qw(examples inc share t) ] };
}

sub __get_notes {
   my $p = shift; my $notes = exists $p->{notes} ? $p->{notes} : {};

   # Optionally create README.md and / or README.pod files
   $notes->{create_readme_md } = defined $p->{create_readme_md}
                               ? $p->{create_readme_md } :  1;
   $notes->{create_readme_pod} = $p->{create_readme_pod} || 0;
   $notes->{is_cpan_testing  } = CPANTesting::is_testing();
   # Add a note to stop CPAN testing if requested in Build.PL
   $notes->{stop_tests       } = CPANTesting::test_exceptions( $p );
   $notes->{url_prefix       } = defined $p->{url_prefix} ? $p->{url_prefix}
                               : q(https://metacpan.org/module/);
   $notes->{version          } = $VERSION;
   return $notes;
}

sub __get_repository { # Accessor for the VCS repository information
   my $repo;

   -d q(.git) and $repo = __get_git_repository() and return $repo;
   -d q(.svn) and $repo = __get_svn_repository() and return $repo;

   return;
}

sub __get_resources {
   my $p         = shift;
   my $distname  = shift;
   my $tracker   = defined $p->{bugtracker}
                 ? $p->{bugtracker}
                 : q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=);
   my $resources = $p->{resources} || {};

   $tracker and $resources->{bugtracker} = $tracker.$distname;
   $p->{home_page} and $resources->{homepage} = $p->{home_page};
   $resources->{license} ||= q(http://dev.perl.org/licenses/);

   # Only get repository info when authoring a distribution
   my $repo; __is_src and $repo = __get_repository
      and $resources->{repository} = $repo;

   return { resources => $resources };
}

sub __get_share_dir {
   my $p = shift; defined $p->{share_dir} and return $p->{share_dir};

   return -d q(share) ? q(share) : undef;
}

sub __get_svn_repository {
   return (grep { ! m{ \A file: }mx }
           (split q( ), (grep { m{ \A URL: }mx }
                            qx{ svn info })[ 0 ])[ 1 ])[ 0 ];
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
