use Test::More;

use strict;
use warnings;

my $hasnt_test_nowarnings;
my $hasnt_test_warn;

BEGIN {

    use Unix::Lsof qw(parse_lsof_output);
    my $SKIP = Unix::Lsof::_find_binary();

    if (!$SKIP) {
        plan skip_all => q{lsof not found in $PATH, please install it (see ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof)};
    } else {
        plan tests => 8;
    }
    use_ok( 'Unix::Lsof' );
    eval ' require Test::NoWarnings;';
    $hasnt_test_nowarnings = 1 if $@;
    eval 'use Test::Warn';
    $hasnt_test_warn = 1 if $@;
}

my @lsof_result;


my $lrs;

ok ( $lrs = parse_lsof_output(["p1111\0g22222\0R3333\0carthur\0u42\0Lzaphod\0","f8\0ar\0l \0tREG\0"]),
     "Successfully parsed known good lsof output");


ok (exists $lrs->{1111},"Correct process number reported");

SKIP: {
    skip "Test::Warn not installed",4 if $hasnt_test_warn;

    # These tests are for the output which caused RT bug numbers 41016 and 43394
    warnings_like { $lrs = parse_lsof_output(["p1111\0Zerror message\0",
                                         "g22222\0R3333\0cford\0u42\0Lzaphod\0",
                                         "f8\0ar\0l \0tREG\0"]) } [
                                                                   qr/lsof result line starts with an invalid field identifier g/,
                                                                   qr/Adding results of this line to process set for PID 1111/,
                                                                   ],
                                                                       "Throws correct warnings with malformed result in process set";

    is ($lrs->{1111}->{"command name"},"ford","Correct command name from second line reported");

    warnings_like { $lrs = parse_lsof_output(["p1111\0Zerror message\0g22222\0R3333\0cford\0u42\0Lzaphod\0",
                                              "f8\0ar\0l \0nnewline\0",
                                              "tREG\0i4242",
                                          ]) } [
                                                qr/lsof result line starts with an invalid field identifier t/,
                                                qr/Adding results of this line to file set line/,
                                            ],
                                                "Survives with malformed result in file set";

    is ($lrs->{1111}{files}[0]{"inode number"},4242,"Correct inode reported");
}

SKIP: {
    skip "Test::NoWarnings not installed", 1 if $hasnt_test_nowarnings;
    Test::NoWarnings->had_no_warnings();
}
