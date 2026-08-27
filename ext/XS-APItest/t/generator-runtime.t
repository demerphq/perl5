#!perl

use strict;
use warnings;

require "../../t/test.pl";
use XS::APItest;

plan(tests => 3);

ok(process_state_roundtrip(), 'process state saves and restores');
is(process_scheduler_reject(), -1, 'scheduler rejects an incomplete setup');
ok(process_scheduler_switch(), 'scheduler alternates independent process states');
