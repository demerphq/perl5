#!./perl

BEGIN {
    chdir 't' if -d 't';
    unshift @INC, '../lib';
}

print "1..57\n";

my $ran = 0;
$_ = 'outside';
my $ok = eval q{
    use feature 'dispatch';
    dispatch (1) {
        on (1) { $ran = 1; }
    }
    1;
};
print !$@ && $ok && $ran ? "ok 1 - case and match syntax\n"
                         : "not ok 1 - case and match syntax\n";

my $off = eval q{ dispatch (1) { on (1) {} } 1 };
print $@ ? "ok 2 - feature gated\n" : "not ok 2 - feature gated\n";

my $nested = eval q{
    use feature 'dispatch';
    dispatch (2) {
        on (1) { die 'wrong arm'; }
        on (2) { $ran = 2; }
    }
    1;
};
print !$@ && $nested && $ran == 2 ? "ok 3 - multiple arms\n"
                                  : "not ok 3 - multiple arms\n";
print $_ eq 'outside' ? "ok 4 - does not leak $_\n"
                      : "not ok 4 - does not leak $_\n";

my ($numeric, $string) = (0, 0);
my $typed_numeric = eval q{
    use feature 'dispatch';
    dispatch (123) {
        on (123) { $numeric = 1; }
        on ('123') { $string = 1; }
    }
    1;
};
my $typed_string = eval q{
    use feature 'dispatch';
    dispatch ('123') {
        on (123) { $numeric = 2; }
        on ('123') { $string = 2; }
    }
    1;
};
print !$@ && $typed_numeric && $typed_string
    && $numeric == 1 && $string == 2
    ? "ok 5 - typed literals\n"
    : "not ok 5 - typed literals\n";

my $wildcard = eval q{
    use feature 'dispatch';
    dispatch (999) {
        on (_) { 1; }
    }
};
print !$@ && $wildcard ? "ok 6 - wildcard\n" : "not ok 6 - wildcard\n";

my ($first, $second, $nested_first, $nested_second);
my $nested = eval q{
    use feature 'dispatch';
    dispatch ([ { foo => 1 }, { foo => 2 } ]) {
        on ([ { foo => $first }, { foo => $second } ]) {
            $nested_first = $first;
            $nested_second = $second;
            1;
        }
    }
};
print !$@ && $nested && $nested_first == 1 && $nested_second == 2
    ? "ok 7 - nested captures\n" : "not ok 7 - nested captures\n";

my $rollback = eval q{
    use feature 'dispatch';
    dispatch ([ { foo => 1 }, { bar => 2 } ]) {
        on ([ { foo => $first }, { foo => $second } ]) { 1; }
    }
};
print !$@ && !defined($rollback)
    ? "ok 8 - failed match rolls back\n"
    : "not ok 8 - failed match rolls back\n";

my $open_array = eval q{
    use feature 'dispatch';
    dispatch ([ 1, 2, 3 ]) {
        on ([ 1, ... ]) { 1; }
    }
    1;
};
print !$@ && $open_array ? "ok 9 - open array pattern\n"
                         : "not ok 9 - open array pattern\n";

my $open_hash = eval q{
    use feature 'dispatch';
    dispatch ({ foo => 1, bar => 2 }) {
        on ({ foo => 1, ... }) { 1; }
    }
    1;
};
print !$@ && $open_hash ? "ok 10 - open hash pattern\n"
                        : "not ok 10 - open hash pattern\n";

my $open_prefix = eval q{
    use feature 'dispatch';
    dispatch ([ 1, 2, 3 ]) {
        on ([ ..., 3 ]) { 1; }
    }
    1;
};
print !$@ && $open_prefix ? "ok 11 - open prefix pattern\n"
                          : "not ok 11 - open prefix pattern\n";

my $subsequence;
my $subsequence_result;
my $open_both = eval q{
    use feature 'dispatch';
    dispatch ([ 0, 'foo', 10, 'bar', 20, 'foo', 30, 'bar' ]) {
        on ([ ..., 'foo', $subsequence, 'bar', ... ]) {
            $subsequence_result = $subsequence;
            1;
        }
    }
    1;
};
print !$@ && $open_both && $subsequence_result == 10
    ? "ok 12 - leftmost subsequence pattern\n"
    : "not ok 12 - leftmost subsequence pattern\n";

my $nested_open;
my $nested_value;
my $nested_value_result;
my $nested_open_ok = eval q{
    use feature 'dispatch';
    dispatch ([ { foo => 1 }, { foo => 2 }, { foo => 3 } ]) {
        on ([ { foo => $nested_value }, ... ]) {
            $nested_open = 1;
            $nested_value_result = $nested_value;
        }
    }
    1;
};
print !$@ && $nested_open_ok && $nested_open && $nested_value_result == 1
    ? "ok 13 - nested open pattern\n"
    : "not ok 13 - nested open pattern\n";

my $dynamic_array = eval q{
    use feature 'dispatch';
    my $offset = 2;
    dispatch ([ 3 ]) {
        on ([ $offset + 1 ]) { 1; }
    }
    1;
};
print !$@ && $dynamic_array ? "ok 14 - dynamic nested array pattern\n"
                            : "not ok 14 - dynamic nested array pattern\n";

my $dynamic_hash = eval q{
    use feature 'dispatch';
    my $offset = 2;
    dispatch ({ foo => 3 }) {
        on ({ foo => $offset + 1 }) { 1; }
    }
    1;
};
print !$@ && $dynamic_hash ? "ok 15 - dynamic nested hash pattern\n"
                           : "not ok 15 - dynamic nested hash pattern\n";

my $regex_match = eval q{
    use feature 'dispatch';
    dispatch ('abc') {
        on (/b/) { 1; }
    }
    1;
};
print !$@ && $regex_match ? "ok 16 - regex pattern\n"
                          : "not ok 16 - regex pattern\n";

{
    package CaseMatch::Tie;
    our $fetches;
    sub TIESCALAR { bless {}, shift }
    sub FETCH { $fetches++; 7 }
    sub STORE { $_[0]{value} = $_[1] }
}

my $subject;
tie $subject, 'CaseMatch::Tie';
my $changed;
my $snapshot = eval q{
    use feature 'dispatch';
    dispatch ($subject) {
        on (7) { $subject = 9; $changed = 1; }
    }
    1;
};
print !$@ && $snapshot && $changed && $CaseMatch::Tie::fetches == 1
    ? "ok 17 - subject fetched once\n"
    : "not ok 17 - subject fetched once\n";
print $subject == 7 ? "ok 18 - arm can write subject\n"
                    : "not ok 18 - arm can write subject\n";

my $arm_result = eval q{
    use feature 'dispatch';
    do {
    dispatch (1) {
            on (1) { 7; 42; }
        }
    }
};
print !$@ && defined($arm_result) && $arm_result == 42
    ? "ok 19 - case returns the arm's last expression\n"
    : "not ok 19 - case returns the arm's last expression\n";

my @arm_result = eval q{
    use feature 'dispatch';
    do {
    dispatch (1) {
            on (1) { (7, 42) }
        }
    }
};
print !$@ && @arm_result == 2 && $arm_result[0] == 7 && $arm_result[1] == 42
    ? "ok 20 - case preserves list context\n"
    : "not ok 20 - case preserves list context\n";

my $no_match = eval q{
    use feature 'dispatch';
    do {
        dispatch (2) {
            on (1) { 42 }
        }
    }
};
my @no_match = eval q{
    use feature 'dispatch';
    do {
        dispatch (2) {
            on (1) { 42 }
        }
    }
};
print !$@ && !defined($no_match) && !@no_match
    ? "ok 21 - no match returns undef or an empty list\n"
    : "not ok 21 - no match returns undef or an empty list\n";

my $default = eval q{
    use feature 'dispatch';
    do {
        dispatch ('other') {
            on ('expected') { die 'wrong arm'; }
            on (_) { 99 }
        }
    }
};
print !$@ && defined($default) && $default == 99
    ? "ok 22 - wildcard arm is the default\n"
    : "not ok 22 - wildcard arm is the default\n";

my $named_subject = eval q{
    use feature qw(dispatch namespaces);
    do {
        dispatch (21 as $bound) {
            on (21) { $bound }
        }
    }
};
print !$@ && defined($named_subject) && $named_subject == 21
    ? "ok 23 - case binds a named subject\n"
    : "not ok 23 - case binds a named subject\n";

my $scope_error = eval q{
    use feature qw(dispatch namespaces);
    no warnings 'syntax';
    do {
        dispatch (21 as $bound) {
            on (21) { 1 }
        }
    }
    $bound;
};
print $@ ? "ok 24 - named subject is case-local\n"
         : "not ok 24 - named subject is case-local\n";

my $guard_capture;
my $guard_fallback = eval q{
    use feature 'dispatch';
    do {
        dispatch ([1]) {
            on ([$guard_capture] if $guard_capture == 2) { die 'wrong arm'; }
            on (_) { 88 }
        }
    }
};
print !$@ && $guard_fallback == 88 && !defined($guard_capture)
    ? "ok 25 - failed guard rolls back captures\n"
    : "not ok 25 - failed guard rolls back captures\n";

my $guard_success = eval q{
    use feature 'dispatch';
    do {
        dispatch ([1]) {
            on ([$guard_capture] if $guard_capture == 1) { $guard_capture }
        }
    }
};
print !$@ && defined($guard_success) && $guard_success == 1
    ? "ok 26 - guard can use captures\n"
    : "not ok 26 - guard can use captures\n";

undef $guard_capture;
my $guard_exception = eval q{
    use feature 'dispatch';
    dispatch ([1]) {
        on ([$guard_capture] if die 'guard failure') { 1 }
    }
};
print $@ && !defined($guard_capture)
    ? "ok 27 - guard exceptions restore captures\n"
    : "not ok 27 - guard exceptions restore captures\n";

my $with_ok = eval q{
    use feature 'dispatch';
    my ($left, $right) = (1, 2);
    dispatch ({ left => 1, right => 2 }) with ($left, $right) {
        on ({ left => $left, right => $right }) { 1 }
    }
};
print !$@ && $with_ok == 1 ? "ok 28 - with pins lexical values\n"
                           : "not ok 28 - with pins lexical values\n";

my $with_mismatch = eval q{
    use feature 'dispatch';
    my $left = 9;
    dispatch ({ left => 1 }) with ($left) {
        on ({ left => $left }) { 1 }
    }
};
print !$@ && !defined($with_mismatch)
    ? "ok 29 - with rejects a mismatched pin\n"
    : "not ok 29 - with rejects a mismatched pin\n";

my $ordinary_case_statement = eval q{
    use feature 'dispatch';
    dispatch (1) {
        1;
        on (1) { 2 }
    }
};
print $@ =~ /only on clauses are allowed directly in a dispatch/
    ? "ok 30 - case body rejects ordinary statements\n"
    : "not ok 30 - case body rejects ordinary statements\n";

my $ordinary_arm_block = eval q{
    use feature 'dispatch';
    dispatch (1) {
        on (1) {
            my $value = 0;
            for (1 .. 2) {
                $value += $_;
            }
            $value;
        }
    }
};
print !$@ && defined($ordinary_arm_block) && $ordinary_arm_block == 3
    ? "ok 31 - match arm retains ordinary block syntax\n"
    : "not ok 31 - match arm retains ordinary block syntax\n";

my $nested_case_in_arm = eval q{
    use feature 'dispatch';
    my $value;
    dispatch (1) {
        on (1) {
            dispatch (2) {
                on (2) { $value = 7 }
            }
        }
    }
    $value;
};
print !$@ && defined($nested_case_in_arm) && $nested_case_in_arm == 7
    ? "ok 32 - nested case is valid inside an arm\n"
    : "not ok 32 - nested case is valid inside an arm\n";

my $nested_case_as_arm = eval q{
    use feature 'dispatch';
    dispatch (1) {
        dispatch (1) { on (1) { 7 } }
    }
};
print $@ =~ /only on clauses are allowed directly in a dispatch/
    ? "ok 33 - nested case is not an arm\n"
    : "not ok 33 - nested case is not an arm\n";

my ($coerced_int, $coerced_float, $coerced_string) = (0, 0, 0);
my ($coerced_undef, $coerced_ref) = (0, 0);
my $typed_subjects = eval q{
    use feature 'dispatch';
    dispatch (IntVal '12') {
        on (12) { $coerced_int = 1 }
    }
    dispatch (FloatVal '2.5') {
        on (2.5) { $coerced_float = 1 }
    }
    dispatch (StrVal 12) {
        on ('12') { $coerced_string = 1 }
    }
    dispatch (StrVal undef) {
        on (undef) { $coerced_undef = 1 }
    }
    my $ref = [];
    dispatch (IntVal $ref) {
        on (_) { $coerced_ref = ref($ref) eq 'ARRAY' }
    }
    1;
};
print !$@ && $typed_subjects && $coerced_int && $coerced_float
    && $coerced_string && $coerced_undef && $coerced_ref
    ? "ok 34 - typed case subjects\n"
    : "not ok 34 - typed case subjects\n";

my $undef_pattern = eval q{
    use feature 'dispatch';
    dispatch (undef) {
        on (undef) { 1 }
    }
};
print !$@ && defined($undef_pattern) && $undef_pattern == 1
    ? "ok 35 - undef is a literal pattern\n"
    : "not ok 35 - undef is a literal pattern\n";

my $typed_reference = [];
my $typed_reference_result = eval q{
    use feature 'dispatch';
    dispatch (StrVal $typed_reference) {
        on ($typed_reference) { 1 }
    }
};
print !$@ && $typed_reference_result
    ? "ok 36 - typed subjects preserve references\n"
    : "not ok 36 - typed subjects preserve references\n";

my ($typed_expression, $typed_parenthesized) = (undef, undef);
my $typed_expression_result = eval q{
    use feature qw(dispatch namespaces);
    my $x = 1;
    dispatch (StrVal $x + 1 as $bound) {
        on ('2') { $typed_expression = $bound }
    }
    dispatch (StrVal($x + 1) as $bound) {
        on ('2') { $typed_parenthesized = $bound }
    }
    1;
};
print !$@ && $typed_expression_result
    && $typed_expression eq '2' && $typed_parenthesized eq '2'
    ? "ok 37 - typed subject expressions bind equivalently\n"
    : "not ok 37 - typed subject expressions bind equivalently\n";

my $with_expression = eval q{
    use feature qw(dispatch namespaces);
    my $base = 4;
    my $evaluations = 0;
    dispatch (8) with (++$evaluations + $base as $expected) {
        on ($expected) { 1 }
    }
    $evaluations == 1;
};
print !$@ && $with_expression
    ? "ok 38 - with expression pins a case-local value\n"
    : "not ok 38 - with expression pins a case-local value\n";

my ($bool_yes, $bool_no, $bool_number) = (0, 0, 0);
my $typed_boolean = eval q{
    use feature 'dispatch';
    use builtin qw(true false);
    dispatch (true)  { on (true)  { $bool_yes = 1 } }
    dispatch (false) { on (false) { $bool_no = 1 } }
    dispatch (1)     { on (true)  { $bool_number = 1 } }
    1;
};
print !$@ && $typed_boolean && $bool_yes && $bool_no && $bool_number
    ? "ok 39 - boolean literals use truth-value semantics\n"
    : "not ok 39 - boolean literals use truth-value semantics\n";

my ($dispatch_order, $dispatch_duplicate, $dispatch_miss) = (0, 0, 0);
my $constant_dispatch = eval q{
    use feature 'dispatch';
    use builtin qw(true false);
    dispatch (1) {
        on ('1') { $dispatch_order = 1 }
        on (true) { $dispatch_order = 2 }
        on (1) { $dispatch_order = 3 }
    }
    dispatch (1) {
        on (1) { $dispatch_duplicate++ }
        on (1) { $dispatch_duplicate += 10 }
    }
    dispatch (3) {
        on (1) { $dispatch_miss = 1 }
    }
    1;
};
print !$@ && $constant_dispatch && $dispatch_order == 2
    && $dispatch_duplicate == 1 && !$dispatch_miss
    ? "ok 40 - constant dispatch preserves typed source order\n"
    : "not ok 40 - constant dispatch preserves typed source order\n";

my ($dispatch_default, $dispatch_early_default) = (0, 0);
my $constant_dispatch_default = eval q{
    use feature 'dispatch';
    dispatch (99) {
        on (1) { $dispatch_default = 1 }
        on (_) { $dispatch_default = 2 }
    }
    dispatch (99) {
        on (_)  { $dispatch_early_default = 3 }
        on (99) { $dispatch_early_default = 4 }
    }
    1;
};
print !$@ && $constant_dispatch_default
    && $dispatch_default == 2 && $dispatch_early_default == 3
    ? "ok 41 - constant dispatch preserves wildcard defaults\n"
    : "not ok 41 - constant dispatch preserves wildcard defaults\n";

my ($empty_default_scalar, @empty_default_list);
my $empty_default_result = eval q{
    use feature 'dispatch';
    $empty_default_scalar = sub {
        dispatch (99) {
            on (1) { 1 }
            on (_) { () }
        }
    }->();
    @empty_default_list = sub {
        dispatch (99) {
            on (1) { 1 }
            on (_) { () }
        }
    }->();
    1;
};
print !$@ && $empty_default_result && !defined($empty_default_scalar)
    && !@empty_default_list
    ? "ok 42 - empty wildcard default preserves context\n"
    : "not ok 42 - empty wildcard default preserves context\n";

my ($last_label, $next_label, $redo_label) = (0, 0, 0);
my $label_control = eval q{
    use feature 'dispatch';
    LABEL_LAST: dispatch (1) {
        on (1) { $last_label = 1; last LABEL_LAST; $last_label = 2 }
    }
    LABEL_NEXT: dispatch (1) {
        on (1) { $next_label = 1; next LABEL_NEXT; $next_label = 2 }
    }
    my $n = 0;
    LABEL_REDO: dispatch (++$n) {
        on (1) { redo LABEL_REDO }
        on (_) { $redo_label = $n }
    }
    1;
};
print !$@ && $label_control && $last_label == 1 && $next_label == 1
    && $redo_label == 2
    ? "ok 43 - labelled case control exits and redoes correctly\n"
    : "not ok 43 - labelled case control exits and redoes correctly\n";

my ($captured_suffix, $unchanged_suffix, $empty_suffix) = ();
my ($captured_suffix_result, $empty_suffix_result);
my $concat_capture = eval q{
    use feature 'dispatch';
    my $text = 'foo_bar';
    dispatch ($text) {
        on ('foo_' . $captured_suffix) {
            $captured_suffix_result = $captured_suffix;
        }
    }
    $text = 'foo_';
    dispatch ($text) {
        on ('foo_' . $empty_suffix) {
            $empty_suffix_result = $empty_suffix;
        }
    }
    $text = 'not_bar';
    $unchanged_suffix = 'OLD';
    dispatch ($text) {
        on ('foo_' . $unchanged_suffix) { 1 }
    }
    1;
};
print !$@ && $concat_capture && $captured_suffix_result eq 'bar'
    && $empty_suffix_result eq '' && $unchanged_suffix eq 'OLD'
    ? "ok 44 - concatenation captures an unpinned suffix\n"
    : "not ok 44 - concatenation captures an unpinned suffix\n";

my ($pinned_match, $pinned_miss) = (0, 0);
my $concat_pin = eval q{
    use feature 'dispatch';
    my $p = 'bar';
    dispatch ('foo_bar') with ($p) {
        on ('foo_' . $p) { $pinned_match = $p eq 'bar' }
    }
    $p = 'baz';
    dispatch ('foo_bar') with ($p) {
        on ('foo_' . $p) { $pinned_miss = 1 }
    }
    1;
};
print !$@ && $concat_pin && $pinned_match && !$pinned_miss
    ? "ok 45 - pinned concatenation compares its complete value\n"
    : "not ok 45 - pinned concatenation compares its complete value\n";

my ($sandwich, $leading, $trailing) = ();
my ($sandwich_result, $leading_result, $trailing_result);
my $concat_shapes = eval q{
    use feature 'dispatch';
    dispatch ('xmiddlez') {
        on ('x' . $sandwich . 'z') { $sandwich_result = $sandwich }
    }
    dispatch ('middlez') {
        on ($leading . 'z') { $leading_result = $leading }
    }
    dispatch ('xmiddle') {
        on ('x' . $trailing) { $trailing_result = $trailing }
    }
    1;
};
print !$@ && $concat_shapes && $sandwich_result eq 'middle'
    && $leading_result eq 'middle' && $trailing_result eq 'middle'
    ? "ok 46 - concatenation supports prefix suffix and sandwich forms\n"
    : "not ok 46 - concatenation supports prefix suffix and sandwich forms\n";

my $strict_wildcard = eval q{
    use v5.45.3;
    use feature 'dispatch';
    dispatch (10) {
        on (_) { 1 }
    }
};
print !$@ && $strict_wildcard
    ? "ok 47 - wildcard works with strict subs\n"
    : "not ok 47 - wildcard works with strict subs\n";

my ($scope_label, $scope_p, $scope_q) = ('outer', 'outer', 'outer');
my @pattern_warnings;
my $implicit_bindings;
{
    local $SIG{__WARN__} = sub { push @pattern_warnings, @_ };
    $implicit_bindings = eval q{
        use strict;
        use warnings;
    use feature 'dispatch';
        dispatch ('pfx_whatzit_thing') {
            on ('pfx_' . $label . '_thing' if $label eq 'whatzit') {
                $scope_label = $label;
            }
        }
        dispatch (['a', 1, 2]) {
            on (['a', $p, $q] if $p == 1) {
                $scope_p = $p;
                $scope_q = $q;
            }
        }
        1;
    };
}
print !$@ && $implicit_bindings && !@pattern_warnings
    && $scope_label eq 'whatzit' && $scope_p == 1 && $scope_q == 2
    ? "ok 48 - pattern names are implicit arm-local bindings\n"
    : "not ok 48 - pattern names are implicit arm-local bindings\n";

my $match_outside_case = eval q{
    use feature 'dispatch';
    on (1) { 1 }
};
print $match_outside_case eq '' && $@ =~ /on clauses are only allowed directly in a dispatch/
    ? "ok 49 - on is forbidden outside dispatch\n"
    : "not ok 49 - on is forbidden outside dispatch\n";

my ($ref_kind, $scalar_kind, $undef_kind, $object_kind, $plain_ref_kind);
my $value_kinds = eval q{
    use feature 'dispatch';
    my $plain = [];
    my $object = bless {}, 'DispatchTestObject';

    dispatch ($plain) {
        on (ObjectVal()) { $object_kind = 1 }
        on (RefVal())    { $ref_kind = 1 }
    }
    dispatch (42) {
        on (RefVal())    { $plain_ref_kind = 1 }
        on (ScalarVal()) { $scalar_kind = 1 }
    }
    dispatch (undef) {
        on (ScalarVal()) { $undef_kind = 1 }
    }
    dispatch ($object) {
        on (ObjectVal()) { $object_kind = 2 }
    }
    1;
};
print !$@ && $value_kinds && $ref_kind == 1
    ? "ok 50 - RefVal matches unblessed references\n"
    : "not ok 50 - RefVal matches unblessed references\n";
print !$@ && $value_kinds && $scalar_kind && !$plain_ref_kind
    ? "ok 51 - ScalarVal matches non-references\n"
    : "not ok 51 - ScalarVal matches non-references\n";
print !$@ && $value_kinds && $undef_kind
    ? "ok 52 - ScalarVal includes undef\n"
    : "not ok 52 - ScalarVal includes undef\n";
print !$@ && $value_kinds && $object_kind == 2
    ? "ok 53 - ObjectVal matches blessed references\n"
    : "not ok 53 - ObjectVal matches blessed references\n";

my ($object_ref, $object_scalar);
my $object_subset = eval q{
    use feature 'dispatch';
    my $plain = {};
    dispatch ($plain) {
        on (ObjectVal()) { $object_ref = 1 }
        on (RefVal())    { $object_ref = 2 }
    }
    dispatch ('value') {
        on (ObjectVal()) { $object_scalar = 1 }
        on (ScalarVal()) { $object_scalar = 2 }
    }
    1;
};
print !$@ && $object_subset && $object_ref == 2
    ? "ok 54 - ObjectVal is a subset of RefVal\n"
    : "not ok 54 - ObjectVal is a subset of RefVal\n";
print !$@ && $object_subset && $object_scalar == 2
    ? "ok 55 - ObjectVal rejects non-references\n"
    : "not ok 55 - ObjectVal rejects non-references\n";

my ($ordinary_ref, $ordinary_scalar, $ordinary_object, $ordinary_subject);
my $ordinary_functions = eval q{
    use feature 'dispatch';
    sub RefVal    { 'ordinary ref function' }
    sub ScalarVal { 'ordinary scalar function' }
    sub ObjectVal { 'ordinary object function' }
    $ordinary_ref = RefVal();
    $ordinary_scalar = ScalarVal();
    $ordinary_object = ObjectVal();
    dispatch (RefVal()) {
        on ('ordinary ref function') { $ordinary_subject = 1 }
    }
    1;
};
print !$@ && $ordinary_functions
    && $ordinary_ref eq 'ordinary ref function'
    && $ordinary_scalar eq 'ordinary scalar function'
    && $ordinary_object eq 'ordinary object function'
    && $ordinary_subject
    ? "ok 56 - criteria names remain ordinary functions outside patterns\n"
    : "not ok 56 - criteria names remain ordinary functions outside patterns\n";
print !$@ && $ordinary_functions && $ordinary_subject
    ? "ok 57 - criteria names remain ordinary in a dispatch subject\n"
    : "not ok 57 - criteria names remain ordinary in a dispatch subject\n";
