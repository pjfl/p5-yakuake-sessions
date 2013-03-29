# Name

Yakuake::Sessions - Session Manager for the Yakuake Terminal Emulator

# Version

0.1.$Revision: 1 $

# Synopsis

    use Yakuake::Sessions;

    exit Yakuake::Sessions->new_with_options( nodebug => 1 )->run;

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

    Project master file

- `storage_class`

    File format used to store session data. Defaults to `JSON`

- `tab_title`

    Default title to apply to tabs

# Subroutines/Methods

## create

    $exit_code = $self->create;

Creates a new session profile in the `profile\_dir`. Calls ["dump"](#dump)

## delete

    $exit_code = $self->delete;

Deletes the specified session profile

## dump

    $exit_code = $self->dump;

Dumps the current sessions to file. For each tab it captures the
current working directory, the command being executed, the tab title text,
and which tab is currently active

## edit

    $exit_code = $self->edit;

Edit a session profile

## edit\_project

    $exit_code = $self->edit_project;

Edit the profile file for the project in the current directory

## list

    $exit_code = $self->list;

List the session profiles stored in the `profile\_dir`

## load

    $exit_code = $self->load;

Load the specified profile, recreating the tabs with their title text,
current working directories and executing commands

## set\_tab\_title

    $exit_code = $self->set_tab_title;

Sets the current tabs title text to the specified value

## set\_tab\_title\_for\_project

    $exit_code = $self->set_tab_title_for_project;

Set the current tabs title text to the default value for the current project

## show

    $exit_code = $self->show;

Display the contents of the specified session profile

# Diagnostics

None

# Dependencies

- [Class::Usul](http://search.cpan.org/perldoc?Class::Usul)
- [File::DataClass](http://search.cpan.org/perldoc?File::DataClass)

# Incompatibilities

None

# Bugs and Limitations

It is necessary to edit new session profiles and manually escape the shell
meta characters embeded in the executing commands

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<Support at RoxSoft dot co dot uk>`

# License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](http://search.cpan.org/perldoc?perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
