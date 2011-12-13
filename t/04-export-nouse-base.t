package Testophile;

use v5.10;

$\ = "\n";
$, = "\n\t";

# note: /bin does not exist on W32 systems. need to 
# attempt adding it here in order to have something
# to find at all.
#
# likely case is that adding it to the the current
# directory is likely to work.

BEGIN   { -d './bin' || mkdir './bin', 0555 or die $!  }
END     { -d './bin' && rmdir './bin'       or die $!  }


use FindBin::libs qw( noprint export nouse ignore= base=lib );
use FindBin::libs qw(   print export nouse ignore= base=bin );

use Test::More tests => 2;

ok( @lib,		'@lib exported' );
ok( @bin,		'@bin exported' );


exit 0;
