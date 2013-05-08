# @(#)Ident: TabTitles.pm 2013-05-08 00:57 pjf ;

package Yakuake::Sessions::TraitFor::TabTitles;

use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moose::Role;
use Class::Usul::Constants;
use Class::Usul::Functions        qw(throw);
use Cwd                           qw(getcwd);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);

requires qw(config_dir yakuake_sessions yakuake_tabs);

has 'tab_title'  => is => 'ro',   isa => NonEmptySimpleStr,
   documentation => 'Default title to apply to tabs',
   default       => sub { $_[ 0 ]->config->tab_title };

# Public methods
sub set_tab_title : method {
   $_[ 0 ]->_set_tab_title( $_[ 0 ]->extra_argv->[ 0 ] ); return OK;
}

sub set_tab_title_for_project : method {
   my $self = shift; $self->_set_project_for_tty;

   my $title = $self->extra_argv->[ 0 ] or throw 'No tab title';

   $self->_set_tab_title( $title ); return OK;
}

# Private methods
sub _set_project_for_tty {
   my $self = shift;

   $self->io( [ $self->config_dir, q(project_).$ENV{TTY} ] )->print( getcwd );
   return;
}

sub _set_tab_title {
   my ($self, $title) = @_; $title ||= $self->tab_title;

   my $sess_id = $self->yakuake_sessions( q(activeSessionId) );
   my $term_id = $self->yakuake_sessions( q(activeTerminalId) );

   $self->yakuake_tabs( q(setTabTitle), $sess_id, "${term_id} ${title}" );
   return;
}

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::TraitFor::TabTitles - Displays the tab title text

=head1 Synopsis

   use Moose;

   extends 'Yakuake::Sessions::Base';
   with    'Yakuake::Sessions::TraitFor::TabTitles';

=head1 Version

This documents version v0.5.$Rev: 1 $ of L<Yakuake::Sessions::TraitFor::TabTitles>

=head1 Description

Methods to set the tab title text

=head1 Configuration and Environment

Requires these attribute; C<config_dir>, C<yakuake_sessions>, and
C<yakuake_tabs>

Defines the following attributes;

=over 3

=item C<tab_title>

Default title to apply to tabs. Defaults to the config class value;
C<Shell>

=back

=head1 Subroutines/Methods

=head2 set_tab_title

   $exit_code = $self->set_tab_title;

Sets the current tabs title text to the specified value. Defaults to the
vale supplied in the configuration

=head2 set_tab_title_for_project

   $exit_code = $self->set_tab_title_for_project;

Set the current tabs title text to the specified value. Must supply a
title text. Will save the project name for use by
C<yakuake_session_tt_cd>

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
