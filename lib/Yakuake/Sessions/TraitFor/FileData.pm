# @(#)Ident: FileData.pm 2013-07-06 17:40 pjf ;

package Yakuake::Sessions::TraitFor::FileData;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 10 $ =~ /\d+/gmx );

use Class::Usul::Constants;
use Class::Usul::Functions  qw( throw );
use File::DataClass::Types  qw( Bool );
use Moo::Role;
use MooX::Options;

requires qw( add_leader clear_sessions config debug dumper file
             get_session_tabs_from_yakuake io loc maybe_add_session
             options next_argv profile_path raise_session run_cmd
             run_cmd_in_tab set_tab_title_for_session storage_class yorn );

# Public attributes
option 'force'   => is => 'ro', isa => Bool, default => FALSE,
   documentation => 'Overwrite the output file if it already exists',
   short         => 'f';

# Public methods
sub dump : method {
   my $self = shift; my $path = $self->next_argv;

   my $session_tabs = $self->get_session_tabs_from_yakuake;

   ($self->debug or not $path) and $self->dumper( $session_tabs );
   $path or return OK; $path = $self->io( $path );

   my $prompt; $path->exists and $path->is_file and not $self->force
      and $prompt = $self->loc( 'Specified file exists, overwrite?' )
      and not $self->yorn( $self->add_leader( $prompt ), FALSE, FALSE )
      and return OK;

   $self->file->data_dump( data          => { sessions => $session_tabs },
                           path          => $path,
                           storage_class => $self->storage_class );
   return OK;
}

sub load : method {
   my ($self, $data_only) = @_; my $path = $self->profile_path;

   $path->exists and $path->is_file
      or throw $self->loc( 'Path [_1] does not exist or is not a file', $path );

   $data_only and return $self->_get_session_tabs_from_file;

   if ($self->options->{detached}) {
      $self->_apply_sessions( $self->_get_session_tabs_from_file ); return OK;
   }

   my $cmd = 'nohup '.$self->config->pathname." -o detached=1 load ${path}";
   my $out = $self->config->logsdir->catfile( 'load_session.out' );

   $self->run_cmd( $cmd, { async => TRUE, out => $out, err => q(out), } );
   return OK;
}

# Private methods
sub _apply_sessions {
   my ($self, $session_tabs) = @_; my $active = FALSE; my $term_id = 0;

   $self->clear_sessions;

   for my $tab (@{ $session_tabs }) {
      my $sess_id = $self->maybe_add_session( $term_id );

      $self->set_tab_title_for_session( $sess_id, $tab->{title} );
      $tab->{cwd   } and $self->run_cmd_in_tab( 'cd '.$tab->{cwd} );
      $tab->{cmd   } and $self->run_cmd_in_tab( $tab->{cmd} );
      $tab->{active} and $active = $sess_id;
      $term_id++;
   }

   $active and $self->raise_session( $active );
   return;
}

sub _get_session_tabs_from_file {
   my $self = shift; my $path = $self->profile_path;

   my $session_tabs = $self->file->data_load
      ( paths => [ $path ], storage_class => $self->storage_class )->{sessions};

   $session_tabs->[ 0 ] or throw $self->loc( 'No session tabs info found' );
   return $session_tabs;
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::TraitFor::FileData - Dumps and loads session data

=head1 Synopsis

   use Moo;

   extends 'Yakuake::Sessions::Base';
   with    'Yakuake::Sessions::TraitFor::FileData';

=head1 Version

This documents version v0.6.$Rev: 10 $ of
L<Yakuake::Sessions::TraitFor::FileData>

=head1 Description

This is a L<Moo::Role> which dumps and loads session data

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<force>

Overwrite the output file if it already exists

=back

=head1 Subroutines/Methods

=head2 dump - Dumps the current sessions to file

   $exit_code = $self->dump;

For each tab it captures the current working directory, the command
being executed, the tab title text, and which tab is currently active

=head2 load - Load the specified profile

   $exit_code = $self->load( $data_only_flag );

Tabs are recreating with their title text, current working directories
and executing commands. If the C<$data_only_flag> is true returns the
session data information but does not apply it

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Usul>

=item L<File::DataClass>

=item L<Moo::Role>

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
