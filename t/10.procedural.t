use Test::More;
use IO::Socket::INET;
use Fatal qw(open close);

use strict;
use warnings;

my $hasnt_test_exception;

BEGIN {

    use Unix::Lsof;
    my $SKIP = Unix::Lsof::_find_binary();

    if (!$SKIP) {
        plan skip_all => q{lsof not found in $PATH, please install it (see ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof)};
    } else {
        plan tests => 14;
    }
    use_ok( 'Unix::Lsof' );
    eval 'use Test::Exception';
    $hasnt_test_exception = 1 if $@;
}

can_ok('Unix::Lsof',qw(lsof parse_lsof_output));
my @lsof_result;

SKIP: {
    skip "Test::Exception not installed", 7 if $hasnt_test_exception;


    lives_ok { @lsof_result = lsof("/doesnaexist") } "survives on non-existing file";
    lives_ok { lsof( {} ) } "finds binary even when not supplied in hashref";
    my $path = $ENV{PATH};
    $ENV{PATH} = "";
    throws_ok { lsof ( {} ) } qr/Cannot find lsof program/, "dies with error when not finding binary in path";
    $ENV{PATH} = $path;
    ok (!scalar keys %{$lsof_result[0]}, "returns an empty list on non-existing file");
    throws_ok { lsof( { binary => "/doesnaexist" } ) } qr/Cannot find lsof program/, "dies with error on missing binary";
    undef $!;
    throws_ok { lsof( { binary => "README" } ) } qr/is not an executable binary/, "dies with error on false binary";
    throws_ok { lsof( { binary => "lib/" } ) } qr/is not an executable binary/, "dies with error on false binary";
}
my $mypid = $$;
my ($result,$err);
open (my $fh,"<","README");
ok (($result,$err) = lsof("README"), "returns ok on examining open file");

ok(exists $result->{$mypid},"A record with the current PID exists");

my $inode = (stat("README"))[1];
is ($result->{$mypid}{files}[0]{"inode number"},$inode,"Correct inode reported");

my $sock = IO::Socket::INET->new(Listen    => 5,
                                 LocalAddr => '127.0.0.1',
                                 LocalPort => 42424,
                                 Proto     => 'tcp');

ok (($result,$err) = lsof("-n","-p",$mypid), "returns ok on examining a process");
close $fh;

my @ipv4 = grep { $_->{"file type"} eq "IPv4" } @{$result->{$mypid}{files}};
is ($ipv4[0]->{"file name"},"127.0.0.1:42424","Found open network socket");

$sock->close();
