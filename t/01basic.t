use common::sense;
use Test::Most tests => 18;
use Log::Any::Test;
use Log::Any qw($log);
use Log::Any::Sugar;
use Test::Log::Any::Sugar;

# Test the variants.
trace 'test inform';
$log->contains_ok(qr/test inform/);

tracef 'test %s %d', 'f', 6;
$log->contains_ok(qr/test f 6/);

tracec { 'test %d %s', 5 + 10 } 'oho';
$log->contains_ok(qr/test 15 oho/);

# Test each logging level.
for(Log::Any::Sugar::LEVELS) {
	test_level $_, $_;
}

# Make sure warn didn't get clobbered.
warning_is { warn 'test' } 'test', 'warn was not clobbered';

# Test all the other aliases got exported correctly.
my %aliases = (
	inform => 'info',
	err => 'error',
	crit => 'critical',
	fatal => 'critical',
);
for(keys %aliases) {
	test_level $_, $aliases{$_};
}

# Make sure warnc and warnf work.
no strict 'refs';
&{"main::warnf"}('ftest %s %s', 'テスト', 'warn');
&{"main::warnc"}(sub { 'ctest %s %f %s', 'うさてゐ', 5/25 }, 'warn');
cmp_deeply $log->msgs, [
	{message => 'ftest テスト warn', category => 'main', level => 'warning'},
	{message => 'ctest うさてゐ 0.200000 warn', category => 'main', level => 'warning'}
], 'warnf and warnc work';
$log->clear;