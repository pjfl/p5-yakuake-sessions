# Name

Yakuake::Sessions - Session Manager for the Yakuake Terminal Emulator

# Version

This documents version v0.6.$Rev: 4 $ of [Yakuake::Sessions](https://metacpan.org/module/Yakuake::Sessions)

# Synopsis

    # To reduce typing define some shell aliases
    alias ys='yakuake_session'

    # Create some Yakuake sessions. Set each session to a different directory.
    # Run some commands in some of the sessions like an HTTP web development
    # server or tail -f on a log file. Set the tab titles for each session.
    # Now create a profile called dev
    ys create dev

    # Subsequently reload the dev profile
    ys load dev

    # Show the contents of the dev profile
    ys show dev

    # Edit the contents of the dev profile
    ys edit dev

    # Delete the dev profile
    ys delete dev

    # Command line help
    ys -? | -H | -h [sub-command] | list_methods | dump_self

# Description

Create, edit, load session profiles for the Yakuake Terminal Emulator. Sets
and manages the tab title text

# Configuration and Environment

Reads configuration from `~/.yakuakue\_sessions/yakuake\_session.json` which
might look like;

    {
       "doc_title": "Perl",
       "tab_title": "Oo.!.oO"
    }

Defines the following list of attributes;

- `dbus`

    Qt communication interface and service name

- `config_dir`

    Directory containing the configuration files. Defaults to
    `~/.yakuake\_sessions`

- `editor`

    The editor used to edit profiles. Can be set from the configuration
    file. Defaults to the environment variable `EDITOR` or if unset
    `emacs`

- `force`

    Overwrite the output file if it already exists

- `profile_dir`

    Directory to store the session profiles in

- `storage_class`

    File format used to store session data. Defaults to the config class
    value; `JSON`

- `tab_title`

    Default title to apply to tabs. Defaults to the config class value;
    `Shell`

Modifies these methods in the base class

- `run`

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

## list

    yakuake_session list

List the session profiles stored in the `profile\_dir`

## load

    yakuake_session load <profile_name>

Load the specified profile, recreating the tabs with their title text,
current working directories and executing commands

## set\_tab\_title

    yakuake_session set_tab_title <title_text>

Sets the current tabs title text to the specified value. Defaults to the
vale supplied in the configuration

## set\_tab\_title\_for\_project

    yakuake_session set_tab_title_for_project <title_text>

Set the current tabs title text to the specified value. Must supply a
title text. Will save the project name for use by
`yakuake_session_tt_cd`

## show

    yakuake_session show <profile_name>

Display the contents of the specified session profile

# Diagnostics

Turning on debug, add `-D` to the command line, causes the session dump
and load subroutines to display the session tabs data

# Dependencies

- [Class::Usul](https://metacpan.org/module/Class::Usul)
- [File::DataClass](https://metacpan.org/module/File::DataClass)
- [Yakuake::Sessions::Config](https://metacpan.org/module/Yakuake::Sessions::Config)

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
