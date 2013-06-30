# @(#)Ident: FileData.pm 2013-06-30 02:24 pjf ;

package Yakuake::Sessions::TraitFor::FileData;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 5 $ =~ /\d+/gmx );

use Class::Usul::Constants;
use Class::Usul::Functions  qw( throw trim zip );
use English                 qw( -no_match_vars );
use File::DataClass::Types  qw( Bool );
use Moo::Role;
use MooX::Options;

requires qw( add_leader config debug dumper extra_argv file get_tab_title
             io loc options profile_path query_dbus run_cmd set_tab_title
             storage_class yakuake_sessions yakuake_tabs yorn );

# Public attributes
option 'force'   => is => 'ro', isa => Bool, default => FALSE,
   documentation => 'Overwrite the output file if it already exists',
   short         => 'f';

# Public methods
sub dump : method {
   my $self = shift; my $path = shift @{ $self->extra_argv };

   my $session_tabs = $self->_get_session_tabs_from_yakuake;

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
   my ($self, $session_tabs) = @_;

   $self->debug and $self->dumper( $session_tabs );
   $self->_clear_sessions; sleep $self->config->no_thrash;

   $self->yakuake_sessions( q(addSession) ) for (1 .. $#{ $session_tabs });

   sleep $self->config->no_thrash; my $active = FALSE; my $term_id = 0;

   for my $tab (@{ $session_tabs }) {
      my $sess_id = int $self->yakuake_tabs( q(sessionAtTab), $term_id++ );

      $self->yakuake_sessions( q(raiseSession), $sess_id );
      $self->_set_tab_title_for_session( $sess_id, $tab->{title} );
      $tab->{cwd}
         and $self->yakuake_sessions( q(runCommand), q(cd ).$tab->{cwd} );
      $tab->{cmd}
         and $self->yakuake_sessions( q(runCommand), $tab->{cmd} );
      $tab->{active} and $active = $sess_id;
   }

   $active and $self->yakuake_sessions( q(raiseSession), $active );
   return;
}

sub _clear_sessions {
   my $self = shift;

   for (grep { m{ /Sessions/ }msx } split m{ \n }msx, $self->query_dbus) {
      $self->query_dbus( $_, q(close) );
   }

   return;
}

sub _get_current_directory {
   my ($self, $pid) = @_; my $cmd = [ qw(pwdx), $pid ];

   my $out = $self->run_cmd( $cmd, { debug => $self->debug } )->stdout;

   return trim( (split m{ : }msx, $out)[ 1 ] );
}

sub _get_executing_command {
   my ($self, $pid, $fgpid) = @_; $pid == $fgpid and return NUL;

   my $cmd = [ qw(ps --format command --no-headers --pid), $fgpid ];

   $cmd = trim $self->run_cmd( $cmd, { debug => $self->debug } )->stdout;

   return $cmd =~ m{ \A perl (.+) $PROGRAM_NAME }msx ? NUL : $cmd;
}

sub _get_session_map {
   my $self      = shift;
   my @sessions  = sort   { $a <=> $b } map { int $_ } split m{ , }msx,
                            $self->yakuake_sessions( q(sessionIdList) );
   my @ksessions = sort   { $a <=> $b } map { (split m{ / }msx, $_)[ -1 ] }
                   grep   { m{ /Sessions/ }msx }
                   split m{ \n }msx, $self->query_dbus;

   return { zip @sessions, @ksessions };
}

sub _get_session_tabs_from_file {
   my $self = shift; my $path = $self->profile_path;

   my $session_tabs = $self->file->data_load
      ( paths => [ $path ], storage_class => $self->storage_class )->{sessions};

   $session_tabs->[ 0 ] or throw $self->loc( 'No session tabs info found' );
   return $session_tabs;
}

sub _get_session_tabs_from_yakuake {
   my $self        = shift;
   my $active_sess = int $self->yakuake_sessions( q(activeSessionId) );
   my @term_ids    = split m{ , }mx,
                        $self->yakuake_sessions( q(terminalIdList) );
   my $session_map = $self->_get_session_map;
   my $tabs        = [];

   for my $term_id (0 .. $#term_ids) {
      my $sess_id  = int $self->yakuake_tabs( q(sessionAtTab), $term_id );
      my $ksess_id = $session_map->{ $sess_id }; defined $ksess_id or next;
      my $ksess    = "/Sessions/${ksess_id}";
      my $fgpid    = $self->query_dbus( $ksess, q(foregroundProcessId) );
      my $pid      = $self->query_dbus( $ksess, q(processId) );

      push @{ $tabs }, {
         tab_no    => $term_id + 1,
         active    => $sess_id == $active_sess,
         cmd       => $self->_get_executing_command( $pid, $fgpid ),
         cwd       => $self->_get_current_directory( $pid ),
         title     => $self->get_tab_title( $sess_id ),
      };
   }

   return $tabs;
}

sub _set_tab_title_for_session {
   my ($self, $sess_id, $tab_title) = @_;

   my $session_map = $self->_get_session_map;
   my $ksess_id    = $session_map->{ $sess_id }; defined $ksess_id or return;
   my $pid         = $self->query_dbus( "/Sessions/${ksess_id}", 'processId' );
   my $cmd         = [ qw( ps --no-headers -o tty -p ), $pid ];
   my $tty_num     = (split m{ [/] }mx, $self->run_cmd( $cmd )->out)[ -1 ];

   return $self->set_tab_title( $sess_id, $tab_title, $tty_num );
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

This documents version v0.6.$Rev: 5 $ of
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
