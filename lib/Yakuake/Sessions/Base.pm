# @(#)Ident: Base.pm 2013-06-30 20:05 pjf ;

package Yakuake::Sessions::Base;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 9 $ =~ /\d+/gmx );

use Class::Usul::Constants;
use Class::Usul::Functions  qw( app_prefix throw trim );
use File::DataClass::Types  qw( ArrayRef Directory HashRef
                                NonEmptySimpleStr Path );
use Moo;
use MooX::Options;
use Scalar::Util            qw( blessed );

extends q(Class::Usul::Programs);

# Override defaults in base class
has '+config_class' => default => sub { 'Yakuake::Sessions::Config' };

# Public attributes
option 'dbus'          => is => 'ro',   isa => ArrayRef[NonEmptySimpleStr],
   documentation       => 'Qt communication interface and service name',
   default             => sub { [ qw( qdbus org.kde.yakuake ) ] };

option 'config_dir'    => is => 'lazy', isa => Directory,
   documentation       => 'Directory to store configuration files',
   coerce              => Directory->coercion;

option 'profile_dir'   => is => 'lazy', isa => Path, coerce => Path->coercion,
   documentation       => 'Directory to store the session profiles',
   default             => sub { [ $_[ 0 ]->config_dir, 'profiles' ] };

option 'storage_class' => is => 'ro',   isa => NonEmptySimpleStr,
   documentation       => 'File format used to store session data',
   default             => sub { $_[ 0 ]->config->storage_class },
   short               => 's';

has 'extensions'   => is => 'lazy', isa => HashRef, init_arg => undef;

has 'profile_path' => is => 'lazy', isa => Path, coerce => Path->coercion,
   init_arg        => undef;

# Public methods
sub query_dbus {
   my $self = shift; my $cmd = [ @{ $self->dbus }, @_ ];

   return trim $self->run_cmd( $cmd, {
      debug => $self->debug, err => 'out' } )->stdout;
}

sub yakuake_sessions {
   my $self = shift; return $self->query_dbus( q(/yakuake/sessions), @_ );
}

sub yakuake_tabs {
   my $self = shift; return $self->query_dbus( q(/yakuake/tabs), @_ );
}

# Private methods
sub _build_config_dir {
   my $self = shift;
   my $home = $self->config->my_home;
   my $dir  = $self->io( [ $home, '.'.(app_prefix blessed $self) ] );

   $dir->exists or $dir->mkpath; return $dir;
}

sub _build_extensions {
   my $self        = shift;
   my $assoc_table = $self->file->dataclass_schema->extensions;
   my $reverse     = {};

   for my $extn (keys %{ $assoc_table }) {
      $reverse->{ $_ } = $extn for (@{ $assoc_table->{ $extn } });
   }

   return $reverse;
}

sub _build_profile_path {
   my $self    = shift;
   my $profile = $self->next_argv
      or throw $self->loc( 'Profile name not specified' );
   my $path    = $self->io( $profile ); $path->exists and return $path;
   my $profdir = $self->profile_dir; $path = $profdir->catfile( $profile );

   $path->exists and return $path;
   $profdir->exists or $profdir->mkpath;
   $profdir->filter( sub { $_->filename =~ m{ \A $profile }mx } );
   $path = ($profdir->all_files)[ 0 ]; defined $path and return $path;

   my $extn    = $self->extensions->{ $self->storage_class } || NUL;

   return $profdir->catfile( $profile.$extn );
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::Base - Attributes and methods for Yakuake session management

=head1 Synopsis

   package Yakuake::Sessions;

   use Moo;

   extends 'Yakuake::Sessions::Base';

=head1 Version

This documents version v0.6.$Rev: 9 $ of L<Yakuake::Sessions::Base>

=head1 Description

Attributes and methods for Yakuake session management

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<config_class>

The name of the configuration class

=item C<dbus>

Qt communication interface and service name

=item C<config_dir>

Directory containing the configuration files. Defaults to
F<~/.yakuake_sessions>

=item C<profile_dir>

Directory to store the session profiles in

=item C<storage_class>

File format used to store session data. Defaults to the config class
value; C<JSON>

=back

=head1 Subroutines/Methods

=head2 query_dbus

   $self->query_dbus( 'dbus_command' );

Performs C<dbus> commands

=head2 yakuake_sessions

   $self->yakuake_sessions( 'session_command' );

Performs session commands, calls L</query_dbus>

=head2 yakuake_tabs

   $self->yakuake_tabs( 'tabs_command' );

Performs tabs commands, calls L</query_dbus>

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Usul>

=item L<File::DataClass>

=item L<Yakuake::Sessions::Config>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
