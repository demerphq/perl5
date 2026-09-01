#!./perl

BEGIN {
    chdir 't' if -d 't';
    unshift @INC, '../lib';
}

print "1..41\n";

my $ran = 0;
$_ = 'outside';
my $ok = eval q{
    use feature 'case_match';
    case (1) {
        match (1) { $ran = 1; }
    }
    1;
};
print !$@ && $ok && $ran ? "ok 1 - case and match syntax\n"
                         : "not ok 1 - case and match syntax\n";

my $off = eval q{ case (1) { match (1) {} } 1 };
print $@ ? "ok 2 - feature gated\n" : "not ok 2 - feature gated\n";

my $nested = eval q{
    use feature 'case_match';
    case (2) {
        match (1) { die 'wrong arm'; }
        match (2) { $ran = 2; }
    }
    1;
};
print !$@ && $nested && $ran == 2 ? "ok 3 - multiple arms\n"
                                  : "not ok 3 - multiple arms\n";
print $_ eq 'outside' ? "ok 4 - does not leak $_\n"
                      : "not ok 4 - does not leak $_\n";

my ($numeric, $string) = (0, 0);
my $typed_numeric = eval q{
    use feature 'case_match';
    case (123) {
        match (123) { $numeric = 1; }
        match ('123') { $string = 1; }
    }
    1;
};
my $typed_string = eval q{
    use feature 'case_match';
    case ('123') {
        match (123) { $numeric = 2; }
        match ('123') { $string = 2; }
    }
    1;
};
print !$@ && $typed_numeric && $typed_string
    && $numeric == 1 && $string == 2
    ? "ok 5 - typed literals\n"
    : "not ok 5 - typed literals\n";

my $wildcard = eval q{
    use feature 'case_match';
    case (999) {
        match (_) { 1; }
    }
};
print !$@ && $wildcard ? "ok 6 - wildcard\n" : "not ok 6 - wildcard\n";

my ($first, $second);
my $nested = eval q{
    use feature 'case_match';
    case ([ { foo => 1 }, { foo => 2 } ]) {
        match ([ { foo => $first }, { foo => $second } ]) { 1; }
    }
};
print !$@ && $nested && $first == 1 && $second == 2
    ? "ok 7 - nested captures\n" : "not ok 7 - nested captures\n";

my $rollback = eval q{
    use feature 'case_match';
    undef $first;
    undef $second;
    case ([ { foo => 1 }, { bar => 2 } ]) {
        match ([ { foo => $first }, { foo => $second } ]) { 1; }
    }
};
print !$@ && !defined($first) && !defined($second)
    ? "ok 8 - failed match rolls back\n"
    : "not ok 8 - failed match rolls back\n";

my $open_array = eval q{
    use feature 'case_match';
    case ([ 1, 2, 3 ]) {
        match ([ 1, ... ]) { 1; }
    }
    1;
};
print !$@ && $open_array ? "ok 9 - open array pattern\n"
                         : "not ok 9 - open array pattern\n";

my $open_hash = eval q{
    use feature 'case_match';
    case ({ foo => 1, bar => 2 }) {
        match ({ foo => 1, ... }) { 1; }
    }
    1;
};
print !$@ && $open_hash ? "ok 10 - open hash pattern\n"
                        : "not ok 10 - open hash pattern\n";

my $open_prefix = eval q{
    use feature 'case_match';
    case ([ 1, 2, 3 ]) {
        match ([ ..., 3 ]) { 1; }
    }
    1;
};
print !$@ && $open_prefix ? "ok 11 - open prefix pattern\n"
                          : "not ok 11 - open prefix pattern\n";

my $subsequence;
my $open_both = eval q{
    use feature 'case_match';
    case ([ 0, 'foo', 10, 'bar', 20, 'foo', 30, 'bar' ]) {
        match ([ ..., 'foo', $subsequence, 'bar', ... ]) { 1; }
    }
    1;
};
print !$@ && $open_both && $subsequence == 10
    ? "ok 12 - leftmost subsequence pattern\n"
    : "not ok 12 - leftmost subsequence pattern\n";

my $nested_open;
my $nested_value;
my $nested_open_ok = eval q{
    use feature 'case_match';
    case ([ { foo => 1 }, { foo => 2 }, { foo => 3 } ]) {
        match ([ { foo => $nested_value }, ... ]) { $nested_open = 1; }
    }
    1;
};
print !$@ && $nested_open_ok && $nested_open && $nested_value == 1
    ? "ok 13 - nested open pattern\n"
    : "not ok 13 - nested open pattern\n";

my $dynamic_array = eval q{
    use feature 'case_match';
    my $offset = 2;
    case ([ 3 ]) {
        match ([ $offset + 1 ]) { 1; }
    }
    1;
};
print !$@ && $dynamic_array ? "ok 14 - dynamic nested array pattern\n"
                            : "not ok 14 - dynamic nested array pattern\n";

my $dynamic_hash = eval q{
    use feature 'case_match';
    my $offset = 2;
    case ({ foo => 3 }) {
        match ({ foo => $offset + 1 }) { 1; }
    }
    1;
};
print !$@ && $dynamic_hash ? "ok 15 - dynamic nested hash pattern\n"
                           : "not ok 15 - dynamic nested hash pattern\n";

my $regex_match = eval q{
    use feature 'case_match';
    case ('abc') {
        match (/b/) { 1; }
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
    use feature 'case_match';
    case ($subject) {
        match (7) { $subject = 9; $changed = 1; }
    }
    1;
};
print !$@ && $snapshot && $changed && $CaseMatch::Tie::fetches == 1
    ? "ok 17 - subject fetched once\n"
    : "not ok 17 - subject fetched once\n";
print $subject == 7 ? "ok 18 - arm can write subject\n"
                    : "not ok 18 - arm can write subject\n";

my $arm_result = eval q{
    use feature 'case_match';
    do {
        case (1) {
            match (1) { 7; 42; }
        }
    }
};
print !$@ && defined($arm_result) && $arm_result == 42
    ? "ok 19 - case returns the arm's last expression\n"
    : "not ok 19 - case returns the arm's last expression\n";

my @arm_result = eval q{
    use feature 'case_match';
    do {
        case (1) {
            match (1) { (7, 42) }
        }
    }
};
print !$@ && @arm_result == 2 && $arm_result[0] == 7 && $arm_result[1] == 42
    ? "ok 20 - case preserves list context\n"
    : "not ok 20 - case preserves list context\n";

my $no_match = eval q{
    use feature 'case_match';
    do {
        case (2) {
            match (1) { 42 }
        }
    }
};
my @no_match = eval q{
    use feature 'case_match';
    do {
        case (2) {
            match (1) { 42 }
        }
    }
};
print !$@ && !defined($no_match) && !@no_match
    ? "ok 21 - no match returns undef or an empty list\n"
    : "not ok 21 - no match returns undef or an empty list\n";

my $default = eval q{
    use feature 'case_match';
    do {
        case ('other') {
            match ('expected') { die 'wrong arm'; }
            match (_) { 99 }
        }
    }
};
print !$@ && defined($default) && $default == 99
    ? "ok 22 - wildcard arm is the default\n"
    : "not ok 22 - wildcard arm is the default\n";

my $named_subject = eval q{
    use feature qw(case_match namespaces);
    do {
        case (21 as $bound) {
            match (21) { $bound }
        }
    }
};
print !$@ && defined($named_subject) && $named_subject == 21
    ? "ok 23 - case binds a named subject\n"
    : "not ok 23 - case binds a named subject\n";

my $scope_error = eval q{
    use feature qw(case_match namespaces);
    no warnings 'syntax';
    do {
        case (21 as $bound) {
            match (21) { 1 }
        }
    }
    $bound;
};
print $@ ? "ok 24 - named subject is case-local\n"
         : "not ok 24 - named subject is case-local\n";

my $guard_capture;
my $guard_fallback = eval q{
    use feature 'case_match';
    do {
        case ([1]) {
            match ([$guard_capture] if $guard_capture == 2) { die 'wrong arm'; }
            match (_) { 88 }
        }
    }
};
print !$@ && $guard_fallback == 88 && !defined($guard_capture)
    ? "ok 25 - failed guard rolls back captures\n"
    : "not ok 25 - failed guard rolls back captures\n";

my $guard_success = eval q{
    use feature 'case_match';
    do {
        case ([1]) {
            match ([$guard_capture] if $guard_capture == 1) { $guard_capture }
        }
    }
};
print !$@ && defined($guard_success) && $guard_success == 1
    ? "ok 26 - guard can use captures\n"
    : "not ok 26 - guard can use captures\n";

undef $guard_capture;
my $guard_exception = eval q{
    use feature 'case_match';
    case ([1]) {
        match ([$guard_capture] if die 'guard failure') { 1 }
    }
};
print $@ && !defined($guard_capture)
    ? "ok 27 - guard exceptions restore captures\n"
    : "not ok 27 - guard exceptions restore captures\n";

my $with_ok = eval q{
    use feature 'case_match';
    my ($left, $right) = (1, 2);
    case ({ left => 1, right => 2 }) with ($left, $right) {
        match ({ left => $left, right => $right }) { 1 }
    }
};
print !$@ && $with_ok == 1 ? "ok 28 - with pins lexical values\n"
                           : "not ok 28 - with pins lexical values\n";

my $with_mismatch = eval q{
    use feature 'case_match';
    my $left = 9;
    case ({ left => 1 }) with ($left) {
        match ({ left => $left }) { 1 }
    }
};
print !$@ && !defined($with_mismatch)
    ? "ok 29 - with rejects a mismatched pin\n"
    : "not ok 29 - with rejects a mismatched pin\n";

my $ordinary_case_statement = eval q{
    use feature 'case_match';
    case (1) {
        1;
        match (1) { 2 }
    }
};
print $@ =~ /only match arms are allowed directly in a case/
    ? "ok 30 - case body rejects ordinary statements\n"
    : "not ok 30 - case body rejects ordinary statements\n";

my $ordinary_arm_block = eval q{
    use feature 'case_match';
    case (1) {
        match (1) {
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
    use feature 'case_match';
    my $value;
    case (1) {
        match (1) {
            case (2) {
                match (2) { $value = 7 }
            }
        }
    }
    $value;
};
print !$@ && defined($nested_case_in_arm) && $nested_case_in_arm == 7
    ? "ok 32 - nested case is valid inside an arm\n"
    : "not ok 32 - nested case is valid inside an arm\n";

my $nested_case_as_arm = eval q{
    use feature 'case_match';
    case (1) {
        case (1) { match (1) { 7 } }
    }
};
print $@ =~ /only match arms are allowed directly in a case/
    ? "ok 33 - nested case is not an arm\n"
    : "not ok 33 - nested case is not an arm\n";

my ($coerced_int, $coerced_float, $coerced_string) = (0, 0, 0);
my ($coerced_undef, $coerced_ref) = (0, 0);
my $typed_subjects = eval q{
    use feature 'case_match';
    case (IntVal '12') {
        match (12) { $coerced_int = 1 }
    }
    case (FloatVal '2.5') {
        match (2.5) { $coerced_float = 1 }
    }
    case (StrVal 12) {
        match ('12') { $coerced_string = 1 }
    }
    case (StrVal undef) {
        match (undef) { $coerced_undef = 1 }
    }
    my $ref = [];
    case (IntVal $ref) {
        match (_) { $coerced_ref = ref($ref) eq 'ARRAY' }
    }
    1;
};
print !$@ && $typed_subjects && $coerced_int && $coerced_float
    && $coerced_string && $coerced_undef && $coerced_ref
    ? "ok 34 - typed case subjects\n"
    : "not ok 34 - typed case subjects\n";

my $undef_pattern = eval q{
    use feature 'case_match';
    case (undef) {
        match (undef) { 1 }
    }
};
print !$@ && defined($undef_pattern) && $undef_pattern == 1
    ? "ok 35 - undef is a literal pattern\n"
    : "not ok 35 - undef is a literal pattern\n";

my $typed_reference = [];
my $typed_reference_result = eval q{
    use feature 'case_match';
    case (StrVal $typed_reference) {
        match ($typed_reference) { 1 }
    }
};
print !$@ && $typed_reference_result
    ? "ok 36 - typed subjects preserve references\n"
    : "not ok 36 - typed subjects preserve references\n";

my ($typed_expression, $typed_parenthesized) = (undef, undef);
my $typed_expression_result = eval q{
    use feature qw(case_match namespaces);
    my $x = 1;
    case (StrVal $x + 1 as $bound) {
        match ('2') { $typed_expression = $bound }
    }
    case (StrVal($x + 1) as $bound) {
        match ('2') { $typed_parenthesized = $bound }
    }
    1;
};
print !$@ && $typed_expression_result
    && $typed_expression eq '2' && $typed_parenthesized eq '2'
    ? "ok 37 - typed subject expressions bind equivalently\n"
    : "not ok 37 - typed subject expressions bind equivalently\n";

my $with_expression = eval q{
    use feature qw(case_match namespaces);
    my $base = 4;
    my $evaluations = 0;
    case (8) with (++$evaluations + $base as $expected) {
        match ($expected) { 1 }
    }
    $evaluations == 1;
};
print !$@ && $with_expression
    ? "ok 38 - with expression pins a case-local value\n"
    : "not ok 38 - with expression pins a case-local value\n";

my ($bool_yes, $bool_no, $bool_number) = (0, 0, 0);
my $typed_boolean = eval q{
    use feature 'case_match';
    use builtin qw(true false);
    case (true)  { match (true)  { $bool_yes = 1 } }
    case (false) { match (false) { $bool_no = 1 } }
    case (1)     { match (true)  { $bool_number = 1 } }
    1;
};
print !$@ && $typed_boolean && $bool_yes && $bool_no && $bool_number
    ? "ok 39 - boolean literals use truth-value semantics\n"
    : "not ok 39 - boolean literals use truth-value semantics\n";

my ($dispatch_order, $dispatch_duplicate, $dispatch_miss) = (0, 0, 0);
my $constant_dispatch = eval q{
    use feature 'case_match';
    use builtin qw(true false);
    case (1) {
        match ('1') { $dispatch_order = 1 }
        match (true) { $dispatch_order = 2 }
        match (1) { $dispatch_order = 3 }
    }
    case (1) {
        match (1) { $dispatch_duplicate++ }
        match (1) { $dispatch_duplicate += 10 }
    }
    case (3) {
        match (1) { $dispatch_miss = 1 }
    }
    1;
};
print !$@ && $constant_dispatch && $dispatch_order == 2
    && $dispatch_duplicate == 1 && !$dispatch_miss
    ? "ok 40 - constant dispatch preserves typed source order\n"
    : "not ok 40 - constant dispatch preserves typed source order\n";

my ($dispatch_default, $dispatch_early_default) = (0, 0);
my $constant_dispatch_default = eval q{
    use feature 'case_match';
    case (99) {
        match (1) { $dispatch_default = 1 }
        match (_) { $dispatch_default = 2 }
    }
    case (99) {
        match (_)  { $dispatch_early_default = 3 }
        match (99) { $dispatch_early_default = 4 }
    }
    1;
};
print !$@ && $constant_dispatch_default
    && $dispatch_default == 2 && $dispatch_early_default == 3
    ? "ok 41 - constant dispatch preserves wildcard defaults\n"
    : "not ok 41 - constant dispatch preserves wildcard defaults\n";
