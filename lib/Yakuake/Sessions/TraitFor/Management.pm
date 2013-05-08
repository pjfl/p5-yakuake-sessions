# @(#)Ident: Management.pm 2013-05-08 00:55 pjf ;

package Yakuake::Sessions::TraitFor::Management;

use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moose::Role;
use Class::Usul::Constants;
use Class::Usul::Functions        qw(say throw);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);

requires qw(dump load profile_dir profile_path);

# Object attributes (public)
has 'editor'     => is => 'ro', isa => NonEmptySimpleStr, lazy => TRUE,
   documentation => 'Which text editor to use',
   default       => sub { $_[ 0 ]->config->editor };

# Public methods
sub create : method {
   my $self = shift; my $path = $self->profile_path;

   $path->assert_filepath; push @{ $self->extra_argv }, $path;
   return $self->dump;
}

sub delete : method {
   my $self = shift; my $path = $self->profile_path;

   $path->exists or throw error => 'Path [_1] not found', args => [ $path ];
   $path->unlink;
   return OK;
}

sub edit : method {
   my $self = shift; my $path = $self->profile_path;

   $self->run_cmd( $self->editor.SPC.$path, { async => TRUE, } );
   return OK;
}

sub list : method {
   my $self     = shift;
   my @suffixes = keys %{ $self->file->dataclass_schema->extensions };

   say map { $_->basename( @suffixes ) } $self->profile_dir->all_files;
   return OK;
}

sub show : method {
   my $self = shift; $self->dumper( $self->load( TRUE ) ); return OK;
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::TraitFor::Management - CRUD methods for session profiles

=head1 Synopsis

   use Moose;

   extends 'Yakuake::Sessions::Base';
   with    'Yakuake::Sessions::TraitFor::Management';

=head1 Version

This documents version v0.5.$Rev: 1 $ of L<Yakuake::Sessions::TraitFor::Management>

=head1 Description

Create, retrieve, update, and delete methods for session profiles

=head1 Configuration and Environment

Requires these attributes; C<dump>, C<load>, C<profile_dir>, and
C<profile_path>

Defines the following attributes;

=over 3

=item C<editor>

The editor used to edit profiles. Can be set from the configuration
file. Defaults to the environment variable C<EDITOR> or if unset
C<emacs>

=back

=head1 Subroutines/Methods

=head2 create

   $exit_code = $self->create;

Creates a new session profile in the C<profile_dir>

=head2 delete

   $exit_code = $self->delete;

Deletes the specified session profile

=head2 edit

   $exit_code = $self->edit;

Edit a session profile

=head2 list

   $exit_code = $self->list;

List the session profiles stored in the C<profile_dir>

=head2 show

   $exit_code = $self->show;

Display the contents of the specified session profile

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Usul>

=item L<Moose::Role>

=item L<MooseX::Types::Common>

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
