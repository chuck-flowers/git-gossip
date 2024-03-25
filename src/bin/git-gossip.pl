#!/usr/bin/env perl

use v5.10;
use feature 'signatures';
use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Git;

my $VERSION = '0.0.0';

my $file;
my $version;
GetOptions(
	'file=s' => \$file,
	'version' => \$version,
);

# Print version if requested
if ($version) {
	say("git-gossip v$VERSION");
	exit 0;
}

# Get the specified command
my $verb = shift @ARGV;
die('No command specified') if not defined $verb;

show() if $verb eq 'show';
clean($file) if $verb eq 'clean';
smudge() if $verb eq 'smudge';

die("The command '$verb' is not recognized");

sub init {
	# TODO
}

sub show {
	my $config = parseConfig();

	for my $file (Git::command('ls-tree', '-r', '--name-only', '--full-tree', 'HEAD')) {
		my $fileConfig = $config->{$file};
		if (defined $fileConfig) {
			say $file;
			for my $secret (keys $fileConfig->{secrets}->%*) {
				my $placeholder = $fileConfig->{secrets}->{$secret}->{placeholder};

				# TODO: Read current value

				say "\t$secret: ? => $placeholder";
			}
		}
	}

	exit 0;
}

sub clean ($name) {
	die 'No filename provided' if not defined $name;

	cleanEnv($name) if $name =~ '^\.env$' or $name =~ '^\.env\.';
	cleanJson($name) if $name =~ '\.json$';

	exit 0;
}

sub cleanEnv ($name) {
	my $config = parseConfig();

	my $fileConfig = $config->{$name};

	while (<>) {
		my $line = $_;
		if ($line =~ '^(\w+)=(.*)$') {
			my $secretConfig = $fileConfig->{secrets}->{$1};
			if (defined($secretConfig)) {
				my $placeholder = $secretConfig->{placeholder};
				say "$1=$placeholder";
			} else {
				print $line;
			}
		} else {
			print $line
		}
	}
}

sub cleanJson ($name) {
	# Make sure there's a configuration for the file
	my $config = parseConfig();
	my $fileConfig = $config->{$name};
	if (not defined($fileConfig)) {
		while (<>) {
			print
		}
	}

	# Construct the necessary JQ command
	my $jqQuery = '';
	for my $secret (keys $fileConfig->{secrets}->%*) {
		my $placeholder = $fileConfig->{secrets}->{$secret}->{placeholder};
		my $clause = "if getpath(path(\$line)) != null then setpath(path(\$line); \"$placeholder\") else . end";
		if ($jqQuery eq '') {
			$jqQuery = $clause;
		} else {
			$jqQuery = "$jqQuery | $clause";
		}
	}
}

sub smudge {
	my $config = parseConfig();
	say 'TODO: Smudge';

	exit 0;
}

sub parseConfig {
	my $localConfig = getLocalConfigPath();
	# Read lines from config file
	my $lines = cleanConfig($localConfig);

	my $config = {};

	my $line;
	while ($line = shift @{$lines}) {
		# Extract the pattern from the header
		$line =~ '^\[(.*)\]$' or die('Failed to parse header of config file');
		my $pattern = $1;

		my $secrets = {};
		while ($line = shift @{$lines}) {
			if ($line =~ '^\t([^=]+)=(.*)$') {
				$secrets->{$1} = { placeholder => $2 };
			} else {
				unshift @{$lines}, $line;
				last;
			}

			$config->{$pattern} = { secrets => $secrets};
		}
	}

	return $config;
}

sub getLocalConfigPath {
	my $repoRoot = Git::command 'rev-parse', '--show-toplevel';
	chomp $repoRoot;
	return $repoRoot . '/.gitgossip';
}

sub cleanConfig ($filename) {
	open FH, '<', $filename;

	my $lines = [];
	while (<FH>) {
		my $line = $_;

		# Ignore blank lines and comments
		next if $line =~ '^\s*$';
		next if $line =~ '^\s*#';

		push @{$lines}, $line;
	}

	close FH;

	return $lines;
}

