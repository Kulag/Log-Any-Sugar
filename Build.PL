#! /usr/bin/env perl

use strict;
use warnings;

use Module::Build 0.3601;

my %module_build_args = (
	'dist_abstract' => 'Extra sugar for your logging pony',
	'license'       => 'isc',
	'dist_name'     => 'Log::Any::Sugar',
	'dist_author'   => 'Kulag',
	'module_name'   => 'Log::Any::Sugar',
	'requires'      => {
		'Log::Any'          => '0',
		'Log::Any::Adapter::Dispatch' => '0',
	},
);

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
