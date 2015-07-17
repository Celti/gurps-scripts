#!/usr/bin/perl
# GURPS Point Calculator (Web Edition)
# Intended to read character sheets from dokuwiki pages and provide output to be displayed via AJAX.
# Meant for use at https://celti.name/wiki/gaming/
# (c) 2007-2015 Patrick Burroughs (Celti) <celti@celti.name>

use common::sense;

my $data_dir = '/home/public/wiki/data/pages/';
my $page_name = $ENV{'QUERY_STRING'};

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

die "Attempt to access files outside of data directory!" if $page_name =~ /\.\.\//;
open my $sheet, "<", $data_dir.$page_name or die "Couldn't open character sheet.";

while (<$sheet>) {
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

print "Content-type: text/html\n\n";
printf "%d points (%d disadvantages)<br/>", sum(@points), sum(@disads);
printf "\$%.2f, %.2f lbs. (%.2f kg.)<br/>", sum(@money), sum(@weight), sum(@weight)/2.205;
printf "<p>[%s]</p><p>&lt;%s&gt;</p><p>{%s}</p><p>|%s|</p>", sum(@points), sum(@angle), sum(@curly), sum(@pipe);
