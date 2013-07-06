# @(#)Ident: DBus.pm 2013-07-06 18:19 pjf ;

package Yakuake::Sessions::TraitFor::DBus;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 10 $ =~ /\d+/gmx );

use Class::Usul::Constants;
use Class::Usul::Functions  qw( trim zip );
use Class::Usul::Time       qw( nap );
use Class::Usul::Types      qw( ArrayRef NonEmptySimpleStr );
use English                 qw( -no_match_vars );
use Moo::Role;
use MooX::Options;

requires qw( debug run_cmd );

# Public attributes
option 'dbus'    => is => 'ro',   isa => ArrayRef[NonEmptySimpleStr],
   documentation => 'Qt communication interface and service name',
   default       => sub { [ qw( qdbus org.kde.yakuake ) ] };

# Public methods
sub clear_sessions {
   my $self = shift; $self->raise_session( $self->_get_session_at_tab( 0 ) );

   $self->_close_session( $_ ) for (reverse $self->_list_sessions);

   return;
}

sub get_active_session_id {
   return int $_[ 0 ]->_yakuake_sessions( 'activeSessionId' );
}

sub get_session_map {
   return { zip $_[ 0 ]->_get_session_ids, $_[ 0 ]->_list_sessions };
}

sub get_session_process_id {
   return $_[ 0 ]->_query_dbus( '/Sessions/'.$_[ 1 ], 'processId' );
}

sub get_session_tabs_from_yakuake {
   my $self        = shift;
   my $active_sess = $self->get_active_session_id;
   my @term_ids    = $self->_get_terminal_ids;
   my $session_map = $self->get_session_map;
   my $tabs        = [];

   for my $term_id (0 .. $#term_ids) {
      my $sess_id  = $self->_get_session_at_tab( $term_id );
      my $ksess_id = $session_map->{ $sess_id }; defined $ksess_id or next;
      my $fgpid    = $self->_get_session_fg_process_id( $ksess_id );
      my $pid      = $self->get_session_process_id( $ksess_id );

      push @{ $tabs }, {
         tab_no    => $term_id + 1,
         active    => $sess_id == $active_sess,
         cmd       => $self->_get_executing_command( $pid, $fgpid ),
         cwd       => $self->_get_current_directory( $pid ),
         title     => $self->_get_tab_title( $sess_id ),
      };
   }

   return $tabs;
}

sub maybe_add_session {
   my ($self, $term_id) = @_;

   my $sess_id = $self->_get_session_at_tab( $term_id );

   $term_id or return $sess_id;

   my $old_id  = $sess_id; $self->_yakuake_sessions( 'addSession' );

   while ($old_id == $sess_id) {
      nap 0.6; $sess_id = $self->get_active_session_id;
   }

   return $sess_id;
}

sub raise_session {
   return $_[ 0 ]->_yakuake_sessions( 'raiseSession', $_[ 1 ] );
}

sub run_cmd_in_tab {
   return $_[ 0 ]->_yakuake_sessions( 'runCommand', $_[ 1 ] );
}

sub set_session_tab_title {
   return shift->_yakuake_tabs( 'setTabTitle', @_ );
}

# Private methods
sub _close_session {
   return $_[ 0 ]->_query_dbus( '/Sessions/'.$_[ 1 ], 'close' );
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

sub _get_session_at_tab {
   return int $_[ 0 ]->_yakuake_tabs( 'sessionAtTab', $_[ 1 ] );
}

sub _get_session_fg_process_id {
   return $_[ 0 ]->_query_dbus( '/Sessions/'.$_[ 1 ], 'foregroundProcessId' );
}

sub _get_session_ids {
   return ( sort   { $a <=> $b }
            map    { int $_ }
            split m{ , }msx, $_[ 0 ]->_yakuake_sessions( 'sessionIdList' ) );
}

sub _get_tab_title {
  (my $title = $_[ 0 ]->_yakuake_tabs( 'tabTitle', $_[ 1 ] ))
      =~ s{ \A \d+ \s+ }{}mx;

   return $title;
}

sub _get_terminal_ids {
   return ( split m{ , }msx, $_[ 0 ]->_yakuake_sessions( 'terminalIdList' ) );
}

sub _list_sessions {
   return ( sort   { $a <=> $b }
            map    { (split m{ / }msx, $_)[ -1 ] }
            grep   { m{ /Sessions/ }msx }
            split m{ \n }msx, $_[ 0 ]->_query_dbus );
}

sub _query_dbus {
   my $self = shift; my $cmd = [ @{ $self->dbus }, @_ ];

   return trim $self->run_cmd( $cmd, {
      debug => $self->debug, err => 'out' } )->stdout;
}

sub _yakuake_sessions {
   return shift->_query_dbus( '/yakuake/sessions', @_ );
}

sub _yakuake_tabs {
   return shift->_query_dbus( '/yakuake/tabs', @_ );
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::TraitFor::DBus - One-line description of the modules purpose

=head1 Synopsis

   use Yakuake::Sessions::TraitFor::DBus;
   # Brief but working code examples

=head1 Version

This documents version v0.1.$Rev: 10 $ of L<Yakuake::Sessions::TraitFor::DBus>

=head1 Description

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<dbus>

Qt communication interface and service name

=back

=head1 Subroutines/Methods

=head2 clear_sessions

=head2 get_active_session_id

=head2 get_session_map

=head2 get_session_process_id

=head2 get_session_tabs_from_yakuake

=head2 maybe_add_session

=head2 raise_session

=head2 run_cmd_in_tab

=head2 set_session_tab_title

=head2 _get_tab_title

   $title_text = $self->get_tab_title( $sess_id );

Returns the tab title text for the session. The session defaults to the
currently active one

=head2 _query_dbus

   $self->_query_dbus( 'dbus_command' );

Performs C<dbus> commands

=head2 _yakuake_sessions

   $self->_yakuake_sessions( 'session_command' );

Performs session commands, calls L</_query_dbus>

=head2 _yakuake_tabs

   $self->_yakuake_tabs( 'tabs_command' );

Performs tabs commands, calls L</_query_dbus>

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Usul>

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
