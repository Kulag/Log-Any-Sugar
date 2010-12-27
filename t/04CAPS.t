use common::sense;
use Test::Most tests => 14;
use Test::Log::Any::Sugar;
use Log::Any::Sugar qw(:CAPS);

my %aliases = Log::Any::Sugar::ALIASES;
for(Log::Any::Sugar::LEVELS, keys %aliases) {
	test_level $_, (defined $aliases{$_} ? $aliases{$_} : $_), 1;
}