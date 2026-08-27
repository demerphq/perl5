#!./perl

use strict;
use warnings;
use Test::More tests => 30;

use feature 'generator';

sub next_values {
    my ($generator) = @_;
    my @values = $generator->();
    return \@values;
}

my $finite = generator {
    yield 1;
    yield 2;
};

is_deeply(next_values($finite), [ 1 ], 'first yield');
is_deeply(next_values($finite), [ 2 ], 'second yield');
is_deeply(next_values($finite), [], 'exhaustion returns an empty list');
my $exhausted = eval { $finite->(); 1 };
ok(!$exhausted, 'exhaustion is permanent');
like($@, qr/cannot resume an exhausted generator/, 'exhaustion diagnostic');

my $undef = generator { yield undef };
my $undef_values = next_values($undef);
is(scalar(@$undef_values), 1, 'undef is still one yielded value');
ok(!defined($undef_values->[0]), 'yielded undef is preserved');

my $n = 10;
my $closure = generator { yield $n++; yield $n++ };
is_deeply(next_values($closure), [ 10 ], 'generator closes over lexical state');
is_deeply(next_values($closure), [ 11 ], 'lexical state survives suspension');

my $loop = generator {
    for my $value (1 .. 3) {
        yield $value;
    }
};
is_deeply(next_values($loop), [ 1 ], 'loop yield one');
is_deeply(next_values($loop), [ 2 ], 'loop yield two');
is_deeply(next_values($loop), [ 3 ], 'loop yield three');
is_deeply(next_values($loop), [], 'loop generator exhausts');

my $inner_eval = generator {
    my $ignored = eval { die "inner failure\n" };
    yield $@;
};
like($inner_eval->(), qr/inner failure/, 'inner eval catches its failure');
is_deeply(next_values($inner_eval), [], 'inner-eval generator exhausts');

my $failed = generator {
    yield 'before failure';
    die "generator failure\n";
};
is_deeply(next_values($failed), [ 'before failure' ], 'failure follows a yield');
my $failure = eval { $failed->(); 1 };
ok(!$failure, 'failure is reported by resume');
like($@, qr/generator failure/, 'original failure is rethrown');
my $resumed_failed = eval { $failed->(); 1 };
ok(!$resumed_failed, 'failed generator cannot be resumed');
like($@, qr/cannot resume a failed generator/, 'failed-resume diagnostic');

my $args = generator { yield 1 };
eval { $args->(1) };
like($@, qr/generator does not accept arguments/, 'arguments are rejected');

my $scalar = generator { yield 42 };
is(scalar($scalar->()), 42, 'scalar context returns the yielded value');

my $list_context = generator {
    yield wantarray ? 'list' : 'scalar';
};
is_deeply(next_values($list_context), [ 'list' ],
    'generator body sees list context');
my $scalar_context = generator {
    yield wantarray ? 'list' : 'scalar';
};
is($scalar_context->(), 'scalar', 'generator body sees scalar context');

my $saved_input_separator = $/;
my $localized = generator {
    local $/ = 'generator separator';
    yield $/;
    yield $/;
};
is_deeply(next_values($localized), [ 'generator separator' ],
    'localization survives the first suspension');
is_deeply(next_values($localized), [ 'generator separator' ],
    'localization survives the second suspension');
is_deeply(next_values($localized), [], 'localized generator exhausts');
is($/, $saved_input_separator, 'localization is restored at exhaustion');

my $reentrant;
$reentrant = generator { yield $reentrant->() };
my $reentered = eval { $reentrant->(); 1 };
ok(!$reentered, 're-entrant resume is rejected');
like($@, qr/generator has no suspended continuation/,
    're-entrant resume diagnostic');
