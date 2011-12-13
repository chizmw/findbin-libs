package Testophile;

use v5.10;

use Test::More tests => 2;

BEGIN   { mkdir './blib/foo', 0555  }
END     { rmdir './blib/foo'        }

require FindBin::libs;

FindBin::libs->import( qw( base=blib subdir=foo subonly ) );

ok $INC[0] =~ m{/blib/foo$}, 'Found only foo subdir';

FindBin::libs->import;

ok $INC[0] =~ m{/lib$}, 'Added lib dir';

__END__
