#!/usr/bin/perl

use lib './lib/';
use YAML::Tiny;
use strict;
use warnings;
use Carp;
use v5.10;
use Data::Dumper;

########################

my $yaml = YAML::Tiny->read('config.yaml');
my $config = $yaml->[0];

my $mode = $config->{mode};
my @searchTerms = @{$config->{searchTerms}};
my @searchLocations = @{$config->{searchLocations}};
my $destinationDirectory = $config->{destinationDirectory};

########################

#print Dumper(@searchTerms);
#print Dumper(@searchLocations);
#print Dumper($destinationDirectory);

########################

my $findCommand = generateCommand(\@searchLocations, \@searchTerms);

my @files = split('\n', `$findCommand`);
chomp(@files);

#print Dumper(@files);

my $action;

if ($mode eq 'copy') {
	$action = 'cp';
	say 'Copying files to ' . $destinationDirectory;
}
elsif ($mode eq 'move') {
	$action = 'mv';
	say 'Moving files to ' . $destinationDirectory;
}
else {
	say 'Your mode parameter in config.yaml should be either \'copy\' or \'move\' - please fix';
	exit 0;
}

foreach my $file (@files) {

	my $command = $action . ' ' . formatFilename($file) . ' ' . $destinationDirectory . '/';
	#say $command;
	system($command);
}


sub generateCommand {
	my @searchLocations = @{$_[0]};
	my @searchTerms = @{$_[1]};

	my @searchArguments;

	foreach (@searchTerms) {
		#say $_;
		my $argument = '-name \'*' . $_ . '*\'';
		push @searchArguments, $argument;
	}

	my $searchArgument = join(' -o ', @searchArguments);

	#my $findCommand = 'find /Volumes/photo ' . $searchArgument;
	my $findCommand = 'find ' . join(' ', @searchLocations) . ' ' . $searchArgument;
	#say $findCommand;

	return $findCommand;
}

sub formatFilename {
	my $name = shift;
	$name =~ s/ /\\ /g;
	return $name;
}
