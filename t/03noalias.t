use common::sense;
use Test::Most tests => 5;
use Test::Log::Any::Sugar;
use Log::Any::Sugar qw(:NOALIAS);

my %aliases = Log::Any::Sugar::ALIASES;
for(keys %aliases) {
	ok !defined *$_;
}