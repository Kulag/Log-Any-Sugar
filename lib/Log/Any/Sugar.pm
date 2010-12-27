package Log::Any::Sugar;
use Log::Any;

our $VERSION = '0.001';

use constant LEVELS => qw(trace debug info notice warning error critical alert emergency);
my %aliases = (
	inform => 'info',
	'warn' => 'warning',
	err => 'error',
	crit => 'critical',
	fatal => 'critical',
);
sub ALIASES() { %aliases };

sub import {
	my($class, @args) = @_;
	my $all_caps = grep /:CAPS/, @args;
	my $caller = caller;
	my $log = Log::Any->get_logger(category => $caller);
	for my $level (LEVELS) {
		my $levelf = $level . 'f';
		my $levelc = $level . 'c';
		my $is_log = 'is_' . $level;

		my $level_ref = $level;
		my $levelf_ref = "Log::Any::Adapter::Core::$levelf";

		if($all_caps) {
			$level = uc $level;
			$levelf = uc $levelf;
			$levelc = uc $levelc;
		}

		*{"${caller}::$level"} = sub($) {
			$log->$level_ref(@_);
		};
		*{"${caller}::$levelf"} = sub($@) {
			unshift @_, $log;
			goto &$levelf_ref;
		};
		*{"${caller}::$levelc"} = sub(&@) {
			if($log->$is_log) {
				unshift @_, $log, shift->();
				goto &$levelf_ref;
			}
		};
	}

	unless(grep /:NOALIAS/, @args) {
		for my $alias (keys %aliases) {
			my $aliasf = $alias . 'f';
			my $aliasc = $alias . 'c';
			my $level = $aliases{$alias};
			my $levelf = $level . 'f';
			my $levelc = $level . 'c';

			if($all_caps) {
				$alias = uc $alias;
				$aliasf = uc $aliasf;
				$aliasc = uc $aliasc;
				$level = uc $level;
				$levelf = uc $levelf;
				$levelc = uc $levelc;
			}

			if($alias ne 'warn' || grep /:CLOBBERWARN/, @args) {
				*{"${caller}::$alias"} = *{"${caller}::$level"};
			}
			*{"${caller}::$aliasf"} = *{"${caller}::$levelf"};
			*{"${caller}::$aliasc"} = *{"${caller}::$levelc"};
		}
	}
}

=HEAD1 name

Log::Any::Sugar - Extra sugar for your logging pony

=head1 SYNOPSIS

	use Log::Any::Sugar;
	
	inform '<pengvado> generic and uninformative is better than wrong'; # $log->inform(...);
	
	warnf '<pengvado> follow this n step(%s) procedure to get the number of physicalcores.', 'number of cores, must be known in advance.'; # $log->warnf(...);
	
	errorc { My::Exception->new->message('<pengvado> %s')->stringify } '__pleaseborkmygoodcode ?'; # $log->is_error && $log->errorf(..., ...);

=head1 DESCRIPTION

A sugary wrapper around L<Log::Any> which exports three functions for each log level. The first logs the string it's passed. The second logs the string evaluated with sprintf. The third lazily evaluates a coderef, passes the result to sprintf along with any additional arguments, and logs the result.

=head1 EXPORT MODIFIERS

=head2 FUNCTION NAMES

Will only export the requested functions. All special modifiers except :CAPS are disabled when you specify a list of functions.

=head2 :CLOBBERWARN

By default, warn is not exported soas not to clobber L<perlfunc/warn>, though warnf and warnc are. This will enable exporting it. Has no effect in combination with any other import modifier.

CAVEAT: This will only work during compile, like C<use Log::Any::Sugar qw(:CLOBBERWARN)>. C<require Log::Any::Sugar; Log::Any::Sugar->import(qw(:CLOBBERWARN));> will not actually clobber L<perlfunc/warn> however much you may want it to.

=head2 :CAPS

Exports all functions in caps.

=head2 :NOALIAS

Disables the export of all aliases.

=head1 COPYRIGHT

Copyright (c) 2010, Kulag <g.kulag@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.