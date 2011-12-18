########################################################################
# FindBin::libs
#
# pick module code suitable for the running version of perl.
########################################################################

########################################################################
# housekeeping
########################################################################

package FindBin::libs;

our $VERSION=1.58;

# use the older code suitable for v5.8 if we are 
# running on anything before v5.12.

BEGIN
{
$DB::single = 1;

    $^V < v5.12
    ? require FindBin::libs_5_8
    : require FindBin::libs_curr
    ;
}

# keep require happy

1

__END__

=head1 NAME

FindBin::libs - Locate and 'use lib' directories along
the path of $FindBin::Bin to automate locating modules.
Uses File::Spec and Cwd's abs_path to accomodate multiple
O/S and redundant symlinks.

=head1 SYNOPSIS

    # search up $FindBin::Bin looking for ./lib directories
    # and "use lib" them.

    use FindBin::libs;

    # same as above with explicit defaults.

    use FindBin::libs qw( base=lib use=1 noexport noprint );

    # print the lib dir's before using them.

    use FindBin::libs qw( print );

    # find and use lib "altlib" dir's

    use FindBin::libs qw( base=altlib );

    # move starting point from $FindBin::Bin to '/tmp'

    use FindBin::libs qw( Bin=/tmp base=altlib );

    # skip "use lib", export "@altlib" instead.

    use FindBin::libs qw( base=altlib export );

    # find altlib directories, use lib them and export @mylibs

    use FindBin::libs qw( base=altlib export=mylibs use );

    # "export" defaults to "nouse", these two are identical:

    use FindBin::libs qw( export nouse );
    use FindBin::libs qw( export       );

    # use and export are not exclusive:

    use FindBin::libs qw( use export            ); # do both
    use FindBin::libs qw( nouse noexport print  ); # print only
    use FindBin::libs qw( nouse noexport        ); # do nothting at all

    # print a few interesting messages about the 
    # items found.

    use FindBinlibs qw( verbose );

    # turn on a breakpoint after the args are prcoessed, before
    # any search/export/use lib is handled.

    use FindBin::libs qw( debug );

    # prefix PERL5LIB with the lib's found.

    use FindBin::libs qw( perl5lib );

    # find a subdir of the lib's looked for.
    # the first example will use both ../lib and
    # ../lib/perl5; the second ../lib/perl5/frobnicate
    # (if they exist). it can also be used with export
    # and base to locate special configuration dir's.
    #
    # subonly with a base is useful for locating config
    # files. this finds any "./config/mypackage" dir's
    # without including any ./config dir's. the result
    # ends up in @config (see also "export=", above).

    use FindBin::libs qw( subdir=perl5 );

    use FindBin::libs qw( subdir=perl5/frobnicate );

    use FindBin::libs qw( base=config subdir=mypackage subonly export );

    # base and subonly are also useful if your 
    # project is stored in multiple git 
    # repositories. 
    #
    # say you need libs under api_foo/lib from api_bar: a
    # base of the git repository directory with subdir of
    # lib and subonly will pull in those lib dirs.

    use FindBin::libs qw( base=api_foo subdir=lib subonly );

    # no harm in using this multiple times to use
    # or export multple layers of libs.

    use FindBin::libs qw( export                                            );
    use FindBin::libs qw( export=found base=lib                             );
    use FindBin::libs qw( export=binz  base=bin            ignore=/foo,/bar );
    use FindBin::libs qw( export=junk  base=frobnicatorium                  );
    use FindBin::libs qw( export       base=foobar                          );

=head1 DESCRIPTION

=head2 General Use

This module will locate directories along the path to $FindBin::Bin
and "use lib" or export an array of the directories found. The default
is to locate "lib" directories and "use lib" them without printing
the list.

Options controll whether the lib's found are exported into the caller's
space, exported to PERL5LIB, or printed. Exporting or setting perl5lib
will turn off the default of "use lib" so that:

    use FindBin::libs qw( export );
    use FindBin::libs qw( p5lib  );

are equivalent to 

    use FindBin::libs qw( export nouse );
    use FindBin::libs qw( p5lib  nouse );

Combining export with use or p5lib may be useful, p5lib and
use are probably not all that useful together.

=head3 Alternate directory name: 'base'

The basename searched for can be changed via 'base=name' so
that

    use FindBin::libs qw( base=altlib );

will search for directories named "altlib" and "use lib" them.

=head3 Exporting a variable: 'export'

The 'export' option will push an array of the directories found
and takes an optional argument of the array name, which defaults 
to the basename searched for:

    use FindBin::libs qw( export );

will find "lib" directories and export @lib with the
list of directories found.

    use FindBin::libs qw( export=mylibs );

will find "lib" directories and export them as "@mylibs" to
the caller.

If "export" only is given then the "use" option defaults to 
false. So:

    use FindBin::libs qw( export );
    use FindBin::libs qw( export nouse );

are equivalent. This is mainly for use when looking for data
directories with the "base=" argument.

If base is used with export the default array name is the base
directory value:

    use FindBin::libs qw( export base=meta );

exports @meta while

    use FindBin::libs qw( export=metadirs base=meta );

exports @metadirs.

The use and export switches are not exclusive:

    use FindBin::libs qw( use export=mylibs );

will locate "lib" directories, use lib them, and export 
@mylibs into the caller's package. 

=head3 Subdirectories

The "subdir" and "subonly" settings will add or 
exclusively use subdir's. This is useful if some
of your lib's are in ../lib/perl5 along with 
../lib (subdir=perl5) or all of the lib's are 
in ../lib/perl5 (subonly=perl5).

This can also be handy for locating subdir's used
for configuring packages:

    use FindBin::libs qw( export base=config subonly=mypackage );

Will leave @config with any "mypacakge" holding
any "mypackage" subdir's.

=head3 Setting PERL5LIB: p5lib

For cases where the environment is more useful for setting
up library paths "p5lib" can be used to preload this variable.
This is mainly useful for automatically including directories
outside of the parent tree of $FindBin::bin.

For example, using:

    $ export PERL5LIB="/usr/local/foo:/usr/local/bar";

    $ myprog;

or simply

    $ PERL5LIB="/usr/local/lib/foo:/usr/lib/bar" myprog;

(depending on your shell) with #! code including:

    use FindBin::libs qw( p5lib );

will not "use lib" any dir's found but will update PERL5LIB
to something like:

    /home/me/sandbox/branches/lib:/usr/local/lib/foo:/usr/lib/bar

This can make controlling the paths used simpler and avoid
the use of symlinks for some testing (see examples below).

Note that "p5lib" and "nouse" are proably worth 

=head2 Skipping directories

By default, lib directories under / and /usr are
sliently ignored. This normally means that /lib, /usr/lib, and
'/usr/local/lib' are skipped. The "ignore" parameter provides
a comma-separated list of directories to ignore:

    use FindBin::libs qw( ignore=/skip/this,/and/this/also );

will replace the standard list and thus skip "/skip/this/lib"
and "/and/this/also/lib". It will search "/lib" and "/usr/lib"
since the argument ignore list replaces the original one.

=head2 Homegrown Library Management 

An all-too-common occurrance managing perly projects is
being unable to install new modules becuse "it might 
break things", and being unable to test them because
you can't install them. The usual outcome of this is a 
collection of hard-coded

    use lib qw( /usr/local/projectX ... )

code at the top of each #! file that has to be updated by
hand for each new project.

To get away from this you'll often see relative paths
for the lib's, which require running the code from one
specific place. All this does is push the hard-coding
into cron, shell wrappers, and begin blocks.

With FindBin::libs you need suffer no more.

Automatically finding libraries in and above the executable
means you can put your modules into cvs/svn and check them
out with the project, have multiple copies shared by developers,
or easily move a module up the directory tree in a testbed
to regression test the module with existing code. All without
having to modify a single line of code.

=over 4

=item Code-speicfic modules.

Say your sandbox is in ./sandbox and you are currently
working in ./sandbox/projects/package/bin on a perl
executable. You may have some number of modules that
are specific -- or customized -- for this pacakge, 
share some modules within the project, and may want 
to use company-wide modules that are managed out of 
./sandbox in development. All of this lives under a 
./qc tree on the test boxes and under ./production 
on production servers.

For simplicity, say that your sandbox lives in your
home direcotry, /home/jowbloe, as a directory or a
symlink.

If your #! uses FindBin::libs in it then it will
effectively

    use lib
    qw(
        /home/jowbloe/sandbox/lib
        /home/jowbloe/sandbox/project/lib
        /home/jowbloe/sandbox/project/package/lib
    );

if you run /home/jowbloe/sandbox/project/package/bin/foobar.
This will happen the same way if you use a relative or
absolute path, perl -d the thing, or if any of the lib
directories are symlinks outside of your sandbox.

This means that the most specific module directories
("closest" to your executable) will be picked up first.

If you have a version of Frobnicate.pm in your ./package/lib
for modifications fine: you'll use it before the one in 
./project or ./sandbox. 

Using the "p5lib" argument can help in case where some of 
the code lives outside of the sandbox. To test a sandbox
version of some other module:

    use FindBin::libs qw( p5lib );

and

    $ PERL5LIB=/other/sandbox/module foobar;

=item Regression Testing

Everntually, however, you'll need to regression test 
Frobnicate.pm with other modules. 

Fine: move, copy, or symlink it into ./project/lib and
you can merrily run ./project/*/bin/* with it and see 
if there are any problems. In fact, so can the nice 
folks in QC. 

If you want to install and test a new module just 
prefix it into, say, ./sandbox/lib and all the code
that has FindBin::libs will simply use it first. 

=item Testing with Symlinks

$FindBin::Bin is relative to where an executable is started from.
This allows a symlink to change the location of directories used
by FindBin::libs. Full regression testing of an executable can be
accomplished with a symlink:

    ./sandbox
        ./lib -> /homegrown/dir/lib
        ./lib/What/Ever.pm

        ./pre-change
            ./bin/foobar

        ./post-change
            ./lib/What/Ever.pm
            ./bin/foobar -> ../../pre-last-change/bin/foobar

Running foobar symlinked into the post-change directory will
test it with whatever collection of modules is in the post-change
directory. A large regression test on some collection of 
changed modules can be performed with a few symlinks into a 
sandbox area.

=item Managing Configuration and Meta-data Files

The "base" option alters FindBin::libs standard base directory.
This allows for a heirarchical set of metadata directories:

    ./sandbox
        ./meta
        ./project/
            ./meta

        ./project/package
            ./bin
            ./meta

with

    use FindBin::libs qw( base=meta export );

    sub read_meta
    {
        my $base = shift;

        for my $dir ( @meta )
        {
            # open the first one and return
            ...
        }

        # caller gets back empty list if nothing was read.

        ()
    }

=item using "prove" with local modules.

Modules that are not intended for CPAN will not usually have
a Makefile.PL or Build setup. This makes it harder to check
the code via "make test". Instead of hacking a one-time 
Makefile, FindBin::libs can be used to locate modules in 
a "lib" directory adjacent to the "t: directory. The setup
for this module would look like:


    ./t/01.t
    ./t/02.t
    ...

    ./lib/FindBin/libs.pm

since the *.t files use FindBin::libs they can locate the 
most recent version of code without it having to be copied
into a ./blib directory (usually via make) before being
processed. If the module did not have a Makefile this would
allow:

    prove t/*.t;

to check the code.

=head1 Notes

=head2 Alternatives

FindBin::libs was developed to avoid pitfalls with
the items listed below. As of FindBin::libs-1.20,
this is also mutli-platform, where other techniques
may be limited to *NIX or at least less portable.

=item PERL5LIBS

PERL5LIB can be used to accomplish the same directory
lookups as FindBin::libs.  The problem is PERL5LIB often
contains absolte paths and does not automatically change
depending on where tests are run. This can leave you 
modifying a file, changing directory to see if it works
with some other code and testing an unmodified version of 
the code via PERL5LIB. FindBin::libs avoids this by using
$FindBin::bin to reference where the code is running from.

The same is true of trying to use almost any environmental
solution, with Perl's built in mechanism or one based on
$ENV{ PWD } or qx( pwd ).

Aside: Combining an existing PERL5LIB for 
out-of-tree lookups with the "p5lib" option 
works well for most development situations. 

=item use lib qw( ../../../../Lib );

This works, but how many dots do you need to get all
the working lib's into a module or #! code? Class
distrubuted among several levels subdirectories may
have qw( ../../../lib ) vs. qw( ../../../../lib )
or various combinations of them. Validating these by
hand (let alone correcting them) leaves me crosseyed
after only a short session.

=item Anchor on a fixed lib directory.

Given a standard directory, it is possible to use
something like:

    BEGIN
    {
        my ( $libdir ) = $0 =~ m{ ^( .+? )/SOMEDIR/ }x;

        eval "use lib qw( $libdir )";
    }

This looks for a standard location (e.g., /path/to/Mylib)
in the executable path (or cwd) and uses that. 

The main problem here is that if the anchor ever changes
(e.g., when moving code between projects or relocating 
directories now that SVN supports it) the path often has
to change in multiple files. The regex also may have to
support multiple platforms, or be broken into more complicated
File::Spec code that probably looks pretty much like what

    use FindBin::libs qw( base=Mylib )

does anyway.

=head2 FindBin::libs-1.2+ uses File::Spec

In order to accmodate a wider range of filesystems, 
the code has been re-written to use File::Spec for
all directory and volume manglement. 

There is one thing that File::Spec does not handle,
hoever, which is fully reolving absolute paths. That
still has to be handled via abs_path, when it works.

The issue is that File::Spec::rel2abs and 
Cwd::abs_path work differently: abs_path only 
returns true for existing directories and 
resolves symlinks; rel2abs simply prepends cwd() 
to any non-absolute paths.

The difference for FinBin::libs is that 
including redundant directories can lead to 
unexpected results in what gets included; 
looking up the contents of heavily-symlinked 
paths is slow (and has some -- admittedly 
unlikely -- failures at runtime). So, abs_path() 
is the preferred way to find where the lib's 
really live after they are found looking up the 
tree. Using abs_path() also avoids problems 
where the same directory is included twice in a 
sandbox' tree via symlinks.

Due to previous complaints that abs_path did not 
work properly on all systems, the current 
version of FindBin::libs uses File::Spec to 
break apart and re-assemble directories, with 
abs_path used optinally. If "abs_path cwd" works 
then abs_path is used on the directory paths 
handed by File::Spec::catpath(); otherwise the 
paths are used as-is. This may leave users on 
systms with non-working abs_path() having extra
copies of external library directories in @INC.

Another issue is that I've heard reports of 
some systems failing the '-d' test on symlinks,
where '-e' would have succeded. 

=head1 See Also

=over 4

=item File::Spec

This is used for portability in dis- and re-assembling 
directory paths based on $FindBin::Bin.

=back


=head1 BUGS

=over 4

=item 

In order to avoid including junk, FindBin::libs
uses '-d' to test the items before including
them on the library list. This works fine so 
long as abs_path() is used to disambiguate any
symlinks first. If abs_path() is turned off
then legitimate directories may be left off in
whatever local conditions might cause a valid
symlink to fail the '-d' test."

=item

File::Spec 3.16 and prior have a bug in VMS of
not returning an absolute paths in splitdir for
dir's without a leading '.'. Fix for this is to
unshift '', @dirpath if $dirpath[0]. While not a
bug, this is obviously a somewhat kludgy workaround
and should be removed (with an added test for a 
working version) once the File::Spec is fixed.

=head1 AUTHOR

Steven Lembark, Workhorse Computing <lembark@wrkhors.com>

=head1 COPYRIGHT

This code is released under the same terms as Perl-5.8.1 itself,
or any later version of Perl the user prefers.
