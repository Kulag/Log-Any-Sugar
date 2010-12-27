package Test::Log::Any::Sugar;
use common::sense;
use Log::Any::Test;
use Log::Any;
use Test::Deep;
no strict 'refs';

sub import {
	*{caller . '::test_level'} = sub ($;$;$) {
		my($level, $real_level, $CAPS) = @_;
		my $log = Log::Any->get_logger(category => caller);
		my($levelf, $levelc) = ("${level}f", "${level}c");
		
		if($CAPS) {
			$level = uc $level;
			$levelf = uc $levelf;
			$levelc = uc $levelc;
		}
		
		&{"main::$level"}('test ' . $level);
		&{"main::$levelf"}('ftest %s %s', 'テスト', $level);
		&{"main::$levelc"}(sub { 'ctest %s %f %s', 'うさてゐ', 5/25 }, $level);
		cmp_deeply $log->msgs, [
			{message => 'test ' . $level, category => 'main', level => $real_level},
			{message => 'ftest テスト ' . $level, category => 'main', level => $real_level},
			{message => 'ctest うさてゐ 0.200000 ' . $level, category => 'main', level => $real_level}
		], "$level, $levelf, and $levelc work";
		$log->clear;
	};
}

1;