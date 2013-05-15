# @(#)Ident: Config.pm 2013-05-06 19:42 pjf ;

package Yakuake::Sessions::Config;

use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Class::Usul::Moose;
use Class::Usul::Functions qw(untaint_identifier);

extends q(Class::Usul::Config::Programs);

has 'editor'        => is => 'lazy', isa => NonEmptySimpleStr,
   default          => sub { untaint_identifier $ENV{EDITOR} || 'emacs' };

has 'storage_class' => is => 'lazy', isa => NonEmptySimpleStr,
   default          => 'JSON';

has 'tab_title'     => is => 'lazy', isa => NonEmptySimpleStr,
   default          => 'Shell';

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::Config - Attribute initialization from configuration file

=head1 Synopsis

   use Class::Usul::Moose;

   extends q(Class::Usul::Programs);

   has '+config_class' => default => sub { 'Yakuake::Sessions::Config' };

=head1 Version

This documents version v0.5.$Rev: 1 $ of L<Yakuake::Sessions::Config>

=head1 Description

Attribute initialization from configuration file. Any attributes defined
in the class can be set from the configuration file

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<editor>

Defaults to the environment variable C<EDITOR> or if unset
C<emacs>

=item C<storage_class>

Defaults to C<JSON>. Format of the configuration file

=item C<tab_title>

Defaults to C<Shell>. String used for the default tab title text

=back

=head1 Subroutines/Methods

None

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