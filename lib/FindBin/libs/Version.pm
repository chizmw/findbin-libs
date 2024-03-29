package # hide from PAUSE
    FindBin::libs;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

# derived from mst suggestion on #catalyst
use version; our $VERSION = version->new('v1.60');

=head1 NAME

FindBin::libs::Version - The FindBin::libs project-wide version number

=head1 SYNOPSIS

    package FindBin::libs::Whatever;

    # Must be on one line so MakeMaker can parse it.
    use FindBin::libs::Version;  our $VERSION = $FindBin::libs::VERSION;

=head1 DESCRIPTION

Because of the problems coordinating revision numbers in a distributed
version control system and across a directory full of Perl modules, this
module provides a central location for the project's release number.

=head1 IDEA FROM

This idea was taken from L<SVK> and L<Parley>

=cut

1;
