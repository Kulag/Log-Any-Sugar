use common::sense;
use Test::Most tests => 1;
use Test::Log::Any::Sugar;
use Log::Any::Sugar qw(:CLOBBERWARN);

test_level 'warn', 'warning';