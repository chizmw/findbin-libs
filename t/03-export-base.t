#!/usr/bin/perl

package Testophile;

use v5.10;
no warnings;    # avoid extraneous nastygrams about qw

use Test::More tests => 5;

$\ = "\n";
$, = "\n\t";

# export @lib after looking for */lib
# export @found after looking for */blib
# export @binz after looking for */bin, override the 
# "ignore" to search /bin, /usr/bin.
#
# eval necessary for crippled O/S w/ missing/broken symlinks.

BEGIN
{
    eval { symlink qw( /nonexistant/path/to/foobar ./foobar ) }
}

use FindBin::libs qw( export                                            );
use FindBin::libs qw( export=found base=lib                             );
use FindBin::libs qw( export=binz  base=bin            ignore=/foo,/bar );
use FindBin::libs qw( export=junk  base=frobnicatorium                  );
use FindBin::libs qw( export       base=foobar                          );

# clean up temp files on the way out.

unlink './foobar';

ok  @lib,     '@lib exported';
ok  @found,   '@found exported';
ok  @binz,    '@binz exported';
ok ! @junk,    'empty @junk exported';
ok ! @foobar,  'empty @foobar exported';

exit 0;
