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
# {10} |2| {20} |11| |0.5| |0.25| |0.125|

use common::sense;
use List::Util qw(sum0);
use open qw(:std :utf8);

my (@points, @disads);
my (@angle, @curly, @pipe);
my (@money, @weight);

sub commaify {
	my $n = shift;
	my ($i, $f) = split(/(?=\.)/, $n);
	$i =~ s/(?<=\d)(?=(?:\d\d\d)+(?!\d))/,/g;
	$f =~ s/\.?0+$//;
	return $i.$f;
}

while (<>) {
	s/½|1\/2/.5/g;
	s/¼|1\/4/.25/g;
	s/⅛|1\/8/.125/g;

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

my $points = commaify(sum0(@points));
my $disads = commaify(sum0(@disads));
my $angle  = commaify(sum0(@angle));
my $curly  = commaify(sum0(@curly));
my $pipe   = commaify(sum0(@pipe));

my $money    = commaify(sprintf('%.2f',sum0(@money)));
my $standard = commaify(sprintf('%.2f',sum0(@weight)));
my $metric   = commaify(sprintf('%.3f',sum0(@weight)/2.205));

printf "%s points (%s disadvantages)\n", $points, $disads;
printf "Equipment: \$%s, %s lbs. (%s kg.)\n", $money, $standard, $metric;
printf "Other sums: <%s> {%s} |%s|\n", $angle, $curly, $pipe;
