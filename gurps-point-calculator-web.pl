#!/usr/bin/perl
# GURPS Point Calculator (Web Edition)
# Intended to read character sheets from dokuwiki pages and provide output to be displayed via AJAX.
# Meant for use at https://celti.name/wiki/gaming/
# (c) 2007-2015 Patrick Burroughs (Celti) <celti@celti.name>

use common::sense;
use List::Util qw(sum0);

my $data_dir = '/home/public/wiki/data/pages/';
my $page_name = $ENV{'QUERY_STRING'};

die "Attempt to access files outside of data directory!" if $page_name =~ /\.\.\//;
open my $sheet, "<", $data_dir.$page_name or die "Couldn't open character sheet.";

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

while (<$sheet>) {
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

print "Content-type: text/html\n\n";
printf "%s points (%s disadvantages)<br/>", $points, $disads;
printf "\$%s, %s lbs., (%s kg.)<br/>", $money, $standard, $metric;
printf "<p>[%s]</p><p>&lt;%s&gt;</p><p>{%s}</p><p>|%s|</p>", $points, $angle, $curly, $pipe;
