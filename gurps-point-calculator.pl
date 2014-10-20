#!/usr/bin/perl
# GURPS Point Calculator
# (c) 2007-2014 Patrick Burroughs (Celti) <celticmadman@gmail.com>

## Testing:
# Wealth (Filthy Rich) [50]
# Greed (12) [-15]
# Template: Immortal [5]
#    Unaging <5>
# 
# $2, $400, $60K, $800M
# 10.5 lbs., 8 oz.
# {10} |2| {20} |11|

use common::sense;

my (@points, @disads);
my (@angle, @curly, @pipe);
my (@money, @weight);

sub sum {
	my $s = 0;
	($s+=$_) for @_;
	$s =~ s/(?<=\d)(?=(?:\d\d\d)+(?!\d))/,/g;
	return $s;
}

while (<>) {
	s/½|1\/2/.5/g;
	s/\+//g;

	foreach (/\[(-?\d*\.?\d+)\]/g) { push @points, $_; }
	foreach (/\[(-\d*\.?\d+)\]/g)  { push @disads, $_; }

	foreach (/\<(-?\d*\.?\d+)\>/g) { push @angle, $_; }
	foreach (/\{(-?\d*\.?\d+)\}/g) { push @curly, $_; }
	foreach (/\|(-?\d*\.?\d+)\|/g) { push @pipe, $_; }
	
	foreach (/\$(-?(?:\d{1,3},)*\d*\.?\d+(?:K|M|B|T)?)/g) {
		s/,//g;
		$_ *= 1000 if s/K//;
		$_ *= 1000000 if s/M//;
		$_ *= 1000000000 if s/B//;
		$_ *= 1000000000000 if s/T//;
		push @money, $_;
	}

	foreach (/((?:\d{1,3},)*\d*\.?\d+)\s*lbs?\.?/xig)
		{ s/,//g; push @weight, $_; }
	foreach (/((?:\d{1,3},)*\d*\.?\d+)\s*oz\./xig)
		{ s/,//g; push @weight, $_/16; }
}

printf "%s points (%s disadvantages)\n", sum(@points), sum(@disads);
printf "Equipment: \$%s, %s lbs.\n", sum(@money), sum(@weight);
printf "Other sums: <%s> {%s} |%s|\n", sum(@angle), sum(@curly), sum(@pipe);
