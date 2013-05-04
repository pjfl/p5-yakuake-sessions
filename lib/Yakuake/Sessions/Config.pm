# @(#)Ident: Config.pm 2013-05-04 22:07 pjf ;

package Yakuake::Sessions::Config;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 3 $ =~ /\d+/gmx );

use Class::Usul::Moose;
use Class::Usul::Constants;
use Class::Usul::Functions qw(throw);

extends qw(Class::Usul::Config::Programs);

has 'storage_class' => is => 'ro', isa => NonEmptySimpleStr,
   default          => 'JSON';

has 'tab_title'     => is => 'ro', isa => NonEmptySimpleStr,
   default          => 'Shell';

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 Name

Yakuake::Sessions::Config - One-line description of the modules purpose

=head1 Synopsis

   use Yakuake::Sessions::Config;
   # Brief but working code examples

=head1 Version

This documents version v0.1.$Rev: 3 $ of L<Yakuake::Sessions::Config>

=head1 Description

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=back

=head1 Subroutines/Methods

=head1 Diagnostics

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
