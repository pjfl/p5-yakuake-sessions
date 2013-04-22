# @(#)Ident: SubClass.pm 2013-04-22 23:16 pjf ;
# Bob-Version: 1.12

use Pod::Select;

sub ACTION_distmeta {
   my $self = shift;

   $self->notes->{create_readme_md} and $self->_create_readme_md();

   $self->notes->{create_readme_pod} and podselect( {
      -output => q(README.pod) }, $self->dist_version_from );

   return $self->SUPER::ACTION_distmeta;
}

sub ACTION_test {
   my $self = shift; delete $ENV{AUTHOR_TESTING};

   return $self->SUPER::ACTION_test;
}

# Private methods

sub _create_readme_md {
   print "Creating README.md using Pod::Markdown\n"; require Pod::Markdown;

   # Monkey patch Pod::Markdown to allow for configurable URL prefixes
   no warnings qw(redefine); *Pod::Markdown::_resolv_link = \&_my_resolve_link;

   my $self   = shift;
   my $parser = Pod::Markdown->new( url_prefix => $self->notes->{url_prefix} );
   my $path   = $self->dist_version_from;

   open my $in,  '<', $path       or die "Path ${path} cannot open: ${!}";
   $parser->parse_from_filehandle( $in ); close $in;
   open my $out, '>', 'README.md' or die "File README.md cannot open: ${!}";
   print {$out} $parser->as_markdown; close $out;
   return;
}

sub _my_resolve_link {
   my ($self, $cmd, $arg) = @_; local $self->_private->{InsideLink} = 1;

   my ($text, $inferred, $name, $section, $type) =
      map { $_ && $self->interpolate( $_, 1 ) }
      Pod::ParseLink::parselink( $arg );
   my $url = q();

   if    ($type eq q(url)) { $url = $name }
   elsif ($type eq q(man)) {
      my ($page, $part) = $name =~ m{ \A ([^\(]+) (?:[\(] (\S*) [\)])? }mx;
      my $prefix = $self->{man_prefix} || q(http://man.he.net/man);

      $url = $prefix.($part || 1).q(/).($page || $name);
   } else {
      my $prefix = $self->{url_prefix} || q(http://search.cpan.org/perldoc?);

      $name    and $url  = "${prefix}${name}";
      $section and $url .= "#${section}";
   }

   $url and return sprintf '[%s](%s)', ($text || $inferred), $url;

   return sprintf '%s<%s>', $cmd, $arg;
}
