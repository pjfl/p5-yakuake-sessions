# @(#)Ident: Sessions.pm 2013-04-28 22:48 pjf ;

package Yakuake::Sessions;

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev: 5 $ =~ /\d+/gmx );

use Class::Usul::Moose;
use Class::Usul::Constants;
use Class::Usul::Functions       qw(say throw trim zip);
use Cwd                          qw(getcwd);
use English                      qw(-no_match_vars);
use File::DataClass::Constraints qw(Directory Path);

extends q(Class::Usul::Programs);

# Public attributes

has 'dbus'          => is => 'ro',   isa => ArrayRef[NonEmptySimpleStr],
   documentation    => 'Qt communication interface and service name',
   default          => sub { [ qw(qdbus org.kde.yakuake) ] };

has 'config_dir'    => is => 'lazy', isa => Directory, coerce => TRUE,
   documentation    => 'Directory to store configuration files';

has 'force'         => is => 'ro',   isa => Bool, default => FALSE,
   documentation    => 'Overwrite the output file if it already exists',
   traits           => [ 'Getopt' ], cmd_aliases => q(f), cmd_flag => 'force';

has 'profile_dir'   => is => 'lazy', isa => Path, coerce => TRUE,
   documentation    => 'Directory to store the session profiles',
   default          => sub { [ $_[ 0 ]->config_dir, 'profiles' ] };

has 'project_file'  => is => 'lazy', isa => NonEmptySimpleStr,
   documentation    => 'Project master file';

has 'storage_class' => is => 'ro',   isa => NonEmptySimpleStr,
   documentation    => 'File format used to store session data',
   traits           => [ 'Getopt' ], cmd_aliases => q(F), cmd_flag => 'format',
   default          => 'JSON';

has 'tab_title'     => is => 'ro',   isa => NonEmptySimpleStr,
   documentation    => 'Default title to apply to tabs',
   default          => 'Oo.!.oO';

# Private attributes

has '_extensions'   => is => 'lazy', isa => HashRef, reader => 'extensions';

around 'run' => sub {
   my ($next, $self) = @_; $self->quiet( TRUE ); return $self->$next();
};

sub create : method {
   my $self = shift; my $path = $self->_get_profile_path;

   $path->assert_filepath; push @{ $self->extra_argv }, $path;

   return $self->dump;
}

sub delete : method {
   my $self = shift; my $path = $self->_get_profile_path;

   $path->exists or throw error => 'Path [_1] not found', args => [ $path ];
   $path->unlink;
   return OK;
}

sub dump : method {
   my $self = shift; my $path = $self->extra_argv->[ 0 ];

   my $session_tabs = $self->_get_session_tabs;

   ($self->debug or not $path) and $self->dumper( $session_tabs );

   $path or return OK; $path = $self->io( $path );

   $path->is_file and $path->exists and not $self->force
      and not $self->yorn( 'Specified file exists, overwrite?', FALSE, FALSE )
      and return OK;

   $self->file->data_dump( data => { sessions => $session_tabs }, path => $path,
                           storage_class => $self->storage_class );
   return OK;
}

sub edit : method {
   my $self = shift; my $editor = $self->options->{editor} || q(emacs);

   $self->run_cmd( $editor.SPC.$self->_get_profile_path, { async => TRUE } );
   return OK;
}

sub edit_project : method {
   my $self = shift; my $editor = $self->options->{editor} || q(emacs);

   $self->run_cmd( $editor.SPC.$self->project_file, { async => TRUE } );
   return OK;
}

sub list : method {
   my $self     = shift;
   my @suffixes = keys %{ $self->file->dataclass_schema->extensions };

   say map { $_->basename( @suffixes ) } $self->profile_dir->all_files;
   return OK;
}

sub load : method {
   my $self = shift; my $session_tabs = $self->_load;

   $self->debug and $self->dumper( $session_tabs );

   $self->_clear_sessions; sleep $self->config->no_thrash;

   $self->_yakuake_sessions( q(addSession) ) for (1 .. $#{ $session_tabs });

   sleep $self->config->no_thrash; my $active = FALSE; my $term_id = 0;

   for my $tab (@{ $session_tabs }) {
      my $sess_id = int $self->_yakuake_tabs( q(sessionAtTab), $term_id++ );

      $self->_yakuake_sessions( q(raiseSession), $sess_id );
      $self->_yakuake_tabs( q(setTabTitle), $sess_id, $tab->{title} );
      $tab->{cwd}
         and $self->_yakuake_sessions( q(runCommand), q(cd ).$tab->{cwd} );
      $tab->{cmd}
         and $self->_yakuake_sessions( q(runCommand), $tab->{cmd} );
      $tab->{active} and $active = $sess_id;
   }

   $active and $self->_yakuake_sessions( q(raiseSession), $active );
   return OK;
}

sub set_tab_title : method {
   $_[ 0 ]->_set_tab_title( $_[ 0 ]->extra_argv->[ 0 ] ); return OK;
}

sub set_tab_title_for_project : method {
   my $self = shift; my $file = $self->extra_argv->[ 0 ];

   $self->_set_project_for_tty;
   $self->_set_tab_title( $self->_get_tab_title_from_file( $file ) );
   return OK;
}

sub show : method {
   $_[ 0 ]->dumper( $_[ 0 ]->_load ); return OK;
}

# Private methods

sub _build__extensions {
   my $self        = shift;
   my $assoc_table = $self->file->dataclass_schema->extensions;
   my $reverse     = {};

   for my $extn (keys %{ $assoc_table }) {
      $reverse->{ $_ } = $extn for (@{ $assoc_table->{ $extn } });
   }

   return $reverse;
}

sub _build_config_dir {
   my $self = shift; my $path = [ $self->config->my_home, '.yakuake-sessions' ];

   my $io   = $self->io( $path ); $io->exists or $io->mkpath;

   return $io;
}

sub _build_project_file {
   return -f 'dist.ini'    ? 'dist.ini'    :
          -f 'Build.PL'    ? 'Build.PL'    :
          -f 'Makefile.PL' ? 'Makefile.PL' :
          throw 'Project file dist.ini, Build.PL, or Makefile.PL not found';
}

sub _clear_sessions {
   my $self = shift;

   for (grep { m{ /Sessions/ }msx } split m{ \n }msx, $self->_query_dbus) {
      $self->_query_dbus( $_, q(close) );
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

sub _get_profile_path {
   my $self    = shift;
   my $profile = shift @{ $self->extra_argv }
      or throw 'Profile name not specified';
   my $path    = $self->io( $profile ); $path->exists and return $path;
   my $profdir = $self->profile_dir; $path = $profdir->catfile( $profile );

   $path->exists and return $path; $profdir->exists or $profdir->mkpath;

   $profdir->filter( sub { $_->filename =~ m{ \A $profile }mx } );

   $path = ($profdir->all_files)[ 0 ]; defined $path and return $path;

   my $extn    = $self->extensions->{ $self->storage_class } || NUL;

   return $profdir->catfile( $profile.$extn );
}

sub _get_session_map {
   my $self      = shift;
   my @sessions  = sort   { $a <=> $b } map { int $_ } split m{ , }msx,
                            $self->_yakuake_sessions( q(sessionIdList) );
   my @ksessions = sort   { $a <=> $b } map { (split m{ / }msx, $_)[ -1 ] }
                   grep   { m{ /Sessions/ }msx }
                   split m{ \n }msx, $self->_query_dbus;

   return { zip @sessions, @ksessions };
}

sub _get_session_tabs {
   my $self        = shift;
   my $active_sess = int $self->_yakuake_sessions( q(activeSessionId) );
   my @term_ids    = split m{ , }mx,
                        $self->_yakuake_sessions( q(terminalIdList) );
   my $session_map = $self->_get_session_map;
   my $tabs        = [];

   for my $term_id (0 .. $#term_ids) {
      my $sess_id  = int $self->_yakuake_tabs( q(sessionAtTab), $term_id );
      my $ksess_id = $session_map->{ $sess_id }; defined $ksess_id or next;
      my $ksess    = "/Sessions/${ksess_id}";
      my $fgpid    = $self->_query_dbus( $ksess, q(foregroundProcessId) );
      my $pid      = $self->_query_dbus( $ksess, q(processId) );

      push @{ $tabs }, {
         tab_no    => $term_id + 1,
         active    => $sess_id == $active_sess,
         cmd       => $self->_get_executing_command( $pid, $fgpid ),
         cwd       => $self->_get_current_directory( $pid ),
         title     => $self->_yakuake_tabs( q(tabTitle), $sess_id ),
      };
   }

   return $tabs;
}

sub _get_tab_title_from_file {
   my ($self, $file) = @_; $file ||= $self->project_file;

   my $text = (grep { m{ tab-title: }msx } $self->io( $file )->getlines)[ -1 ];

   return trim( (split m{ : }msx, $text || NUL, 2)[ 1 ] );
}

sub _load {
   my $self = shift; my $path = $self->_get_profile_path;

   $path->exists and $path->is_file
      or throw error => 'Path [_1] does not exist or is not a file',
               args  => [ $path ];

   my $session_tabs = $self->file->data_load
      ( paths => [ $path ], storage_class => $self->storage_class )->{sessions};

   $session_tabs->[ 0 ] or throw 'No session tabs info found';

   return $session_tabs;
}

sub _query_dbus {
   my $self = shift; my $cmd = [ @{ $self->dbus }, @_ ];

   return trim $self->run_cmd( $cmd, { debug => $self->debug } )->stdout;
}

sub _set_project_for_tty {
   my $self = shift;

   $self->io( [ $self->config_dir, q(project_).$ENV{TTY} ] )->print( getcwd );
   return;
}

sub _set_tab_title {
   my ($self, $title) = @_; $title ||= $self->tab_title;

   my $sess_id = $self->_yakuake_sessions( q(activeSessionId) );
   my $term_id = $self->_yakuake_sessions( q(activeTerminalId) );

   $self->_yakuake_tabs( q(setTabTitle), $sess_id, "${term_id} ${title}" );
   return;
}

sub _yakuake_sessions {
   my $self = shift; return $self->_query_dbus( q(/yakuake/sessions), @_ );
}

sub _yakuake_tabs {
   my $self = shift; return $self->_query_dbus( q(/yakuake/tabs), @_ );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions - Session Manager for the Yakuake Terminal Emulator

=head1 Version

This documents version v0.3.$Rev: 5 $ of L<Yakuake::Sessions>

=head1 Synopsis

   # To reduce typing define some shell aliases
   alias ep='yakuake_session edit_project ; \
             yakuake_session set_tab_title_for_project'
   alias ys='yakuake_session'

   # Create some Yakuake sessions. Set each session to a different directory.
   # Run some commands in some of the sessions like an HTTP web development
   # server or tail -f on a log file. Set the tab titles for each session.
   # Now create a profile called development
   ys create development

   # To reduce typing create an alias
   alias ysld='cd ; nohup yakuake_session load development \
      1>~/.yakuake-sessions/nohup.out 2>&1'

   # Subsequently reload the development profile
   ysld

   # Edit the project master file
   ep

   # Show the contents of the development profile
   ys show development

   # Edit the contents of the development profile
   ys edit development

   # Command line help
   ys -? | -H | -h [sub-command] | list_methods | dump_self

=head1 Description

Create, edit, load session profiles for the Yakuake Terminal Emulator. Sets
and manages the tab title text

=head1 Configuration and Environment

Defines the following list of attributes;

=over 3

=item C<dbus>

Qt communication interface and service name

=item C<force>

Overwrite the output file if it already exists

=item C<profile_dir>

Directory to store the session profiles in

=item C<project_file>

Project master file, defaults to one of; F<dist.ini>, F<Build.PL>, or
F<Makefile.PL>

=item C<storage_class>

File format used to store session data. Defaults to C<JSON>

=item C<tab_title>

Default title to apply to tabs

=back

=head1 Subroutines/Methods

=head2 create

   yakuake_session create <profile_name>

Creates a new session profile in the F<profile_dir>. Calls L</dump>

=head2 delete

   yakuake_session delete <profile_name>

Deletes the specified session profile

=head2 dump

   yakuake_session dump <path>

Dumps the current sessions to file. For each tab it captures the
current working directory, the command being executed, the tab title text,
and which tab is currently active

=head2 edit

   yakuake_session edit <profile_name>

Edit a session profile

=head2 edit_project

   yakuake_session edit_project

Edit the project file (one of; F<dist.ini>, F<Build.PL>, or
F<Makefile.PL>) in the current directory

=head2 list

   yakuake_session list

List the session profiles stored in the F<profile_dir>

=head2 load

   yakuake_session load <profile_name>

Load the specified profile, recreating the tabs with their title text,
current working directories and executing commands

=head2 set_tab_title

   yakuake_session set_tab_title

Sets the current tabs title text to the specified value

=head2 set_tab_title_for_project

   yakuake_session set_tab_title_for_project

Set the current tabs title text to the default value for the current project

=head2 show

   yakuake_session show <profile_name>

Display the contents of the specified session profile

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Usul>

=item L<File::DataClass>

=back

=head1 Incompatibilities

None

=head1 Bugs and Limitations

It is necessary to edit new session profiles and manually escape the shell
meta characters embeded in the executing commands

There are no known bugs in this module.Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Yakuake-Sessions. Source code
is on Github git://github.com/pjfl/Yakuake-Sessions.git. Patches and
pull requests are welcome

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

