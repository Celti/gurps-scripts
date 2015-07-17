#!/usr/bin/perl
# GURPS Point Calculator
# (c) 2007-2015 Patrick Burroughs (Celti) <celti@celti.name>

## Testing:
# Wealth (Filthy Rich) [50]
# Greed (12) [-15]
# Template: Immortal [5]
#    Unaging <5>
# 
# $2, $400, $60K, $800M
# 10.5 lbs., 19 oz., 2 kg., 400 g.
# {10} |2| {20} |11|

use common::sense;

my (@points, @disads);
my (@angle, @curly, @pipe);
my (@money, @weight);

sub sum {
	my $s = 0;
	($s+=$_) for @_;
	my ($i, $f) = split(/(?=\.)/, $s);
	$i =~ s/(?<=\d)(?=(?:\d\d\d)+(?!\d))/,/g;
	return $i . $f;
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
	foreach (/((?:\d{1,3},)*\d*\.?\d+)\s*kg\./xig)
		{ s/,//g; push @weight, $_*2.205; }
	foreach (/((?:\d{1,3},)*\d*\.?\d+)\s*g\./xig)
		{ s/,//g; push @weight, $_/453.593; }
}

printf "%d points (%d disadvantages)\n", sum(@points), sum(@disads);
printf "Equipment: \$%.2f, %.2f lbs. (%.2f kg.)\n", sum(@money), sum(@weight), sum(@weight)/2.205;
printf "Other sums: <%d> {%d} |%d|\n", sum(@angle), sum(@curly), sum(@pipe);
