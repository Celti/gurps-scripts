#!/usr/bin/perl
# GURPS Aging Calculator
# (c) 2007-2015 Patrick Burroughs (Celti) <celti@celti.name>

use threads;
use threads::shared;

use common::sense;
use Math::NumberCruncher;
use Getopt::Long;

# Set defaults and get variables.
my $iter = 10000; # Number of iterations.
my $maxprocs = 4; # Number of threads.

my $HT = 10; # The character's HT.
my $TL = 8;  # The character's TL.
my $add = 0; # Any additional modifiers to the aging roll.
my $death = 4; # The HT the character is considered to be dead at.

my $lifespan = 0; # Number of levels of Extended Lifepsan.
                  # Negative values indicate levels of Short Lifespan.

my $longevity = 0;     # Does the character have Longevity?
my $self_destruct = 0; # Does the character have Self-Destruct?

my $noisy; # Print debug output?
my $help; # Print usage?

sub usage() {
	say "Unknown option: @_" if (@_);
	print <<EOH;
Usage: $0 [OPTIONS]
  -?, --help            Display this help and exit.
  -v, --log[=?]         Log verbose output to stdout or specified file. (Default: off)
  -h, --ht=?            The character's starting HT. (Default: 10)
  -t, --tl=?            The character's medical TL. (Default: 8)
  -a, --add=?           Additional modifiers to the aging roll. (Default: 0)
  -d, --death=?         The HT the character is considered dead at. (Default: 4)
  -x, --lifespan=?      The character's level of Extended Lifespan.
                        Negative values indicate levels of Short Lifespan. (Default: 0)
  -l, --longevity       The character has Longevity. (Default: off)
  -s, --self-destruct   The character has Self-Destruct. (Default: off)
  -i, --iterations      The number of iterations to calculate. (Default: 10,000)
  -p, --maxprocs        The number of threads to spawn. (Default: 4)
EOH
	exit;
}

usage() if ( ! GetOptions(
	'i|iterations=i' => \$iter,            # -i 10000, --iterations=10000
	'p|maxprocs=i' => \$maxprocs,          # -p 4, --maxprocs=4
	'h|ht=i' => \$HT,                      # -h 10, --ht=10
	't|tl=i' => \$TL,                      # -t 8, --tl=8
	'a|add=i' => \$add,                    # -a 0, --add=0
	'd|death=i' => \$death,                # -d 4, --death=4
	'x|lifespan=i' => \$lifespan,          # -x 0, --lifespan=0
	'l|longevity' => \$longevity,          # -l, --longevity
	's|self-destruct' => \$self_destruct,  # -s, --self-destruct
	'v|log:s' => \$noisy,                    # -v, --log
	'help|?' => \$help                     # -?, --help
) or defined $help );

# Results array, shared between threads.
my @deaths :shared;

# Open debug logfile (default to STDOUT).
my $log = *STDOUT;
if ($noisy and $noisy != 1) {
	open $log, '>', $noisy or die "Couldn't open logfile!";
}

# Extended Lifespan increases the duration between rolls.
my $mod = 2**$lifespan;

# Total bonus to aging rolls.
my $bonus = $TL-3;                # Base bonus is TL-3.
   $bonus -= 3 if $self_destruct; # Self-Destruct subtracts 3.
   $bonus += $add if $add;        # Any additional modifiers.

# Number of iterations per thread.
my $iter_per_proc = $iter / $maxprocs;

sub kill_them_all {
	foreach (1 .. $iter_per_proc) { # How many people shall we slay today?
		my $_HT = $HT; # Let's not modify the global HT.
		my $age = 50*$mod; # You start dying at age fifty (or greater, with Extended Lifespan).
		while ($_HT > $death) { # 'til death do we run.
			my $roll = Math::NumberCruncher::Dice(3,6); # Roll the bones!
			say $log "Current HT is $_HT, effective HT is ".($_HT+$bonus).", current age is $age. Rolled a $roll." if $noisy;

			if ($longevity) {
				if ($_HT+$bonus > 16) {
					$_HT -= 1 if $roll > 17; # Only fail on an 18 with HT 17+.
					say $log "Lost 1 HT." if $noisy and $roll > 17;
				} else {
					$_HT -= 1 if $roll > 16; # Can only fail on a 17 or 18.
					say $log "Lost 1 HT." if $noisy and $roll > 16;
				}
			} else {
				if (($roll > 16) or ($roll > $_HT+$bonus+9)) {
					$_HT -= 2; # Any roll of 17 or 18, or critical failure, is -2 HT.
					say $log "Lost 2 HT." if $noisy;
				} elsif ($roll > $_HT+$bonus) {
					$_HT -= 1; # Normal failure is -1 HT.
					say $log "Lost 1 HT." if $noisy;
				}
			}

			if ($_HT <= $death) {
				push @deaths, $age;
				say $log "Dead at $age.\n%" if $noisy;
			} else {
				if ($self_destruct) {
					$age += $mod/365;
				} elsif ($age < 70*$mod) {
					$age += $mod;
				} elsif ($age < 90*$mod) {
					$age += $mod/2;
				} else {
					$age += $mod/4;
				}
			} # Age one increment and repeat.
		}
	}
}

# Spawn and wait for threads.
map { threads->create(\&kill_them_all)->join() } 1 .. $maxprocs;

# Process and output statistics.
my $mean = Math::NumberCruncher::Mean(\@deaths);
my ($high, $low) = Math::NumberCruncher::Range(\@deaths);
my $median = Math::NumberCruncher::Median(\@deaths);
my $stddev = Math::NumberCruncher::StandardDeviation(\@deaths);

say "Median age of death is $median (highest is $high, lowest is $low).";
say "Mean: $mean; StdDev: $stddev";
