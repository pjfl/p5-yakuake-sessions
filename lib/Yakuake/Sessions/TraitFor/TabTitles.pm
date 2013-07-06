# @(#)Ident: TabTitles.pm 2013-07-06 18:11 pjf ;

package Yakuake::Sessions::TraitFor::TabTitles;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 10 $ =~ /\d+/gmx );

use Class::Usul::Constants;
use Class::Usul::Functions  qw( throw );
use Cwd                     qw( getcwd );
use File::DataClass::Types  qw( NonEmptySimpleStr );
use Moo::Role;
use MooX::Options;

requires qw( config config_dir get_active_session_id get_session_map
             get_session_process_id loc next_argv
             run_cmd set_session_tab_title );

# Public methods
sub set_tab_title : method {
   my ($self, $sess_id, $title, $tty_num) = @_;

   $sess_id //= $self->get_active_session_id;
   $title   //= $self->next_argv || $self->config->tab_title;
   $tty_num //= $ENV{TTY};

   $self->set_session_tab_title( $sess_id, "${tty_num} ${title}" );
   return OK;
}

sub set_tab_title_for_project : method {
   my $self    = shift;
   my $title   = $self->next_argv or throw $self->loc( 'No tab title' );
   my $appbase = $self->next_argv || getcwd;
   my $tty_num = $ENV{TTY};

   $self->set_tab_title( undef, $title, $tty_num );
   $self->config_dir->catfile( "project_${tty_num}" )->println( $appbase );
   return OK;
}

sub set_tab_title_for_session {
   my ($self, $sess_id, $title) = @_;

   my $session_map = $self->get_session_map;
   my $ksess_id    = $session_map->{ $sess_id }; defined $ksess_id or return;
   my $pid         = $self->get_session_process_id( $ksess_id );
   my $cmd         = [ qw( ps --no-headers -o tty -p ), $pid ];
   my $tty_num     = (split m{ [/] }mx, $self->run_cmd( $cmd )->out)[ -1 ];

   $self->log->info( "$title $sess_id $ksess_id $pid $tty_num" );

   return $self->set_tab_title( $sess_id, $title, $tty_num );
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::TraitFor::TabTitles - Displays the tab title text

=head1 Synopsis

   use Moo;

   extends 'Yakuake::Sessions::Base';
   with    'Yakuake::Sessions::TraitFor::TabTitles';

=head1 Version

This documents version v0.6.$Rev: 10 $ of
L<Yakuake::Sessions::TraitFor::TabTitles>

=head1 Description

Methods to set the tab title text

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<tab_title>

Default title to apply to tabs. Defaults to the config class value;
C<Shell>

=back

=head1 Subroutines/Methods

=head2 set_tab_title - Sets the current tabs title text

   $exit_code = $self->set_tab_title;

The value is obtained from the command line. Defaults to the vale
supplied in the configuration

=head2 set_tab_title_for_project - Sets the tab title text for the project

   $exit_code = $self->set_tab_title_for_project;

Set the current tabs title text to the specified value. Must supply a
title text. Will save the project name for use by
C<yakuake_session_tt_cd>

=head2 set_tab_title_for_session

   $self->set_tab_title_for_session( $session_id, $tab_title );

Sets the tab title for the session

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
