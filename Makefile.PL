use v5.8;
use ExtUtils::MakeMaker;

WriteMakefile
(

    # Note to self: use VERSION here since v-strings
    # botch MakeMaker and the modules use v-strings.

    NAME          => 'FindBin::libs',
    VERSION       => '1.59',
    ABSTRACT_FROM => 'lib/FindBin/libs.pm',
    PREREQ_PM     =>
    {
    # standard distro, particular versions 
    # are unlikely to cause pain.

    strict          => 0,
    warnings        => 0,
    Carp            => 0,
    Cwd             => 0,
    FindBin         => 0,
    Symbol          => 0,
    'File::Spec'    => 0,
    'Test::More'    => 0,
    },

);
