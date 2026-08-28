#!./perl

use strict;
use warnings;
BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    set_up_inc('../lib');
}

plan(tests => 46);

use feature 'iterator';

sub next_values {
    my ($iterator) = @_;
    my @values = $iterator->();
    return \@values;
}

sub is_deeply {
    my ($got, $expected, $name) = @_;
    is(join("\x1f", map { defined $_ ? $_ : "\x00" } @$got),
       join("\x1f", map { defined $_ ? $_ : "\x00" } @$expected), $name);
}

my $finite = iterator_create {
    iterator_yield 1;
    iterator_yield 2;
};

ok(!iterator_exhausted $finite, 'new iterator is not exhausted');
is_deeply(next_values($finite), [ 1 ], 'first iterator_yield');
ok(!iterator_exhausted($finite), 'suspended iterator is not exhausted');
is_deeply(next_values($finite), [ 2 ], 'second iterator_yield');
is_deeply(next_values($finite), [], 'exhaustion returns an empty list');
ok(iterator_exhausted $finite, 'completed iterator is exhausted');
my $exhausted = eval { $finite->(); 1 };
ok(!$exhausted, 'exhaustion is permanent');
like($@, qr/cannot resume an exhausted iterator/, 'exhaustion diagnostic');

my $undef = iterator_create { iterator_yield undef };
my $undef_values = next_values($undef);
is(scalar(@$undef_values), 1, 'undef is still one yielded value');
ok(!defined($undef_values->[0]), 'yielded undef is preserved');

my $n = 10;
my $closure = iterator_create { iterator_yield $n++; iterator_yield $n++ };
is_deeply(next_values($closure), [ 10 ], 'iterator closes over lexical state');
is_deeply(next_values($closure), [ 11 ], 'lexical state survives suspension');

my $loop = iterator_create {
    for my $value (1 .. 3) {
        iterator_yield $value;
    }
};
is_deeply(next_values($loop), [ 1 ], 'loop iterator_yield one');
is_deeply(next_values($loop), [ 2 ], 'loop iterator_yield two');
is_deeply(next_values($loop), [ 3 ], 'loop iterator_yield three');
is_deeply(next_values($loop), [], 'loop iterator exhausts');

my $inner_eval = iterator_create {
    my $ignored = eval { die "inner failure\n" };
    iterator_yield $@;
};
like($inner_eval->(), qr/inner failure/, 'inner eval catches its failure');
is_deeply(next_values($inner_eval), [], 'inner-eval iterator exhausts');

my $failed = iterator_create {
    iterator_yield 'before failure';
    die "iterator failure\n";
};
ok(!iterator_exhausted $failed, 'failed iterator is not initially exhausted');
is_deeply(next_values($failed), [ 'before failure' ], 'failure follows a yield');
my ($failure, $failure_error, $resumed_failed, $resumed_failed_error);
{
    local $@;
    $failure = eval { $failed->(); 1 };
    $failure_error = $@;
    $resumed_failed = eval { $failed->(); 1 };
    $resumed_failed_error = $@;
}
ok(!$failure, 'failure is reported by resume');
like($failure_error, qr/iterator failure/, 'original failure is rethrown');
ok(!iterator_exhausted($failed), 'failed iterator is not exhausted');
ok(!$resumed_failed, 'failed iterator cannot be resumed');
like($resumed_failed_error, qr/cannot resume a failed iterator/, 'failed-resume diagnostic');

my $args = iterator_create { iterator_yield 1 };
eval { $args->(1) };
like($@, qr/iterator does not accept arguments/, 'arguments are rejected');

my $scalar = iterator_create { iterator_yield 42 };
is(scalar($scalar->()), 42, 'scalar context returns the yielded value');

my $list_context = iterator_create {
    iterator_yield wantarray ? 'list' : 'scalar';
};
is_deeply(next_values($list_context), [ 'list' ],
    'iterator body sees list context');
my $scalar_context = iterator_create {
    iterator_yield wantarray ? 'list' : 'scalar';
};
is($scalar_context->(), 'scalar', 'iterator body sees scalar context');

my $saved_input_separator = $/;
my $localized = iterator_create {
    local $/ = 'iterator separator';
    iterator_yield $/;
    iterator_yield $/;
};
    is_deeply(next_values($localized), [ 'iterator separator' ],
    'localization survives the first suspension');
is_deeply(next_values($localized), [ 'iterator separator' ],
    'localization survives the second suspension');
is_deeply(next_values($localized), [], 'localized iterator exhausts');
is($/, $saved_input_separator, 'localization is restored at exhaustion');

my $reentrant;
$reentrant = iterator_create { iterator_yield $reentrant->() };
my ($reentered, $reentered_error);
{
    local $@;
    $reentered = eval { $reentrant->(); 1 };
    $reentered_error = $@;
}
ok(!$reentered, 're-entrant resume is rejected');
like($reentered_error, qr/iterator has no suspended continuation/,
    're-entrant resume diagnostic');
$reentrant = undef;

my $nested_inner = iterator_create { iterator_yield 10; iterator_yield 20 };
my $nested_outer = iterator_create {
    iterator_yield $nested_inner->();
    iterator_yield $nested_inner->();
};
is_deeply(next_values($nested_outer), [ 10 ],
    'nested iterator resumes its inner iterator');
is_deeply(next_values($nested_outer), [ 20 ],
    'nested iterator preserves the inner continuation');
is_deeply(next_values($nested_outer), [], 'nested iterator exhausts');

like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'iterator_yield 1'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected outside an iterator');

like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'sub ordinary_iterator_test { iterator_yield 1 }'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected in an ordinary sub');

like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'sort { iterator_yield 1 } 1, 2'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected in sort callbacks');
like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'map { iterator_yield 1 } 1, 2'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected in map callbacks');
like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'grep { iterator_yield 1 } 1, 2'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected in grep callbacks');
like(runperl(switches => ['-Mfeature=iterator'], stderr => 1,
             prog => 'q[a] =~ /(?{ iterator_yield 1 })/'),
    qr/iterator_yield outside an iterator_create/, 'iterator_yield is rejected in regex callbacks');

is(runperl(switches => ['-Mfeature=iterator', '-MScalar::Util=weaken'],
           prog => 'package Generator::Cleanup; sub DESTROY { }'
                . ' package main; my $weak;'
                . ' my $iterator = iterator_create { my $object = bless {},'
                . ' q[Generator::Cleanup]; $weak = $object; weaken($weak);'
                . ' iterator_yield 1 }; $iterator->(); undef $iterator;'
                . ' print defined($weak) ? q[live] : q[destroyed]'),
   'destroyed', 'dropping a suspended iterator releases its pad');

like(runperl(stderr => 1,
             prog => 'my $not_an_iterator = iterator_create { 1 }'),
    qr/Can't locate object method "iterator_create"/,
    'iterator syntax remains feature gated');

undef $finite;
undef $undef;
undef $closure;
undef $loop;
undef $inner_eval;
undef $failed;
undef $args;
undef $scalar;
undef $list_context;
undef $scalar_context;
undef $localized;
undef $nested_outer;
undef $nested_inner;
undef $undef_values;
undef $reentered;
undef $exhausted;
undef $failure;
undef $resumed_failed;
undef $saved_input_separator;
undef $n;
undef $@;
