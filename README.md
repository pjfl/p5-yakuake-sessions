# Name

Yakuake::Sessions - Session Manager for the Yakuake Terminal Emulator

# Version

This documents version v0.3.$Rev: 2 $ of [Yakuake::Sessions](https://metacpan.org/module/Yakuake::Sessions)

# Synopsis

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

# Description

Create, edit, load session profiles for the Yakuake Terminal Emulator

# Configuration and Environment

Defines the following list of attributes;

- `dbus`

    Qt communication interface and service name

- `force`

    Overwrite the output file if it already exists

- `profile_dir`

    Directory to store the session profiles in

- `project_file`

    Project master file, defaults to one of; `dist.ini`, `Build.PL`, or
    `Makefile.PL`

- `storage_class`

    File format used to store session data. Defaults to `JSON`

- `tab_title`

    Default title to apply to tabs

# Subroutines/Methods

## create

    yakuake_session create <profile_name>

Creates a new session profile in the `profile\_dir`. Calls ["dump"](#dump)

## delete

    yakuake_session delete <profile_name>

Deletes the specified session profile

## dump

    yakuake_session dump <path>

Dumps the current sessions to file. For each tab it captures the
current working directory, the command being executed, the tab title text,
and which tab is currently active

## edit

    yakuake_session edit <profile_name>

Edit a session profile

## edit\_project

    yakuake_session edit_project

Edit the project file (one of; `dist.ini`, `Build.PL`, or
`Makefile.PL`) in the current directory

## list

    yakuake_session list

List the session profiles stored in the `profile\_dir`

## load

    yakuake_session load <profile_name>

Load the specified profile, recreating the tabs with their title text,
current working directories and executing commands

## set\_tab\_title

    yakuake_session set_tab_title

Sets the current tabs title text to the specified value

## set\_tab\_title\_for\_project

    yakuake_session set_tab_title_for_project

Set the current tabs title text to the default value for the current project

## show

    yakuake_session show <profile_name>

Display the contents of the specified session profile

# Diagnostics

None

# Dependencies

- [Class::Usul](https://metacpan.org/module/Class::Usul)
- [File::DataClass](https://metacpan.org/module/File::DataClass)

# Incompatibilities

None

# Bugs and Limitations

It is necessary to edit new session profiles and manually escape the shell
meta characters embeded in the executing commands

There are no known bugs in this module.Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Yakuake-Sessions. Source code
is on Github git://github.com/pjfl/Yakuake-Sessions.git. Patches and
pull requests are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
