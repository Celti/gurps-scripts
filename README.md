GURPS-scripts
=============

A collection of scripts for use with the Generic Universal Role-Playing System.

## gurps-aging-calculator.pl
Runs through a number of iterations of the GURPS aging rules using the specified collection of aging-related traits, returning the maximum, minimum, mean, median, and standard deviation.

````
Usage: ./gurps-aging-calculator.pl [OPTIONS]
  -?, --help            Display this help and exit.
  -v, --log             Log verbose output to age-calc.log. (Default: off)
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
````

## gurps-point-calculator.pl
Takes a GURPS character sheet in standard SJGames print format (as used for templates and sample characters in books) and prints out the total point value, disadvantage total, as well as the totals of all values within angle brackets (<0>), curly brackets ({0}), or pipes (|0|), plus the total weight and cost of all values listed on the page (in the format of: $1,000, 10 lbs., 8 oz.). You can get a test run by feeding it to itself: `./gurps-point-calculator.pl gurps-point-calculator.pl`.
