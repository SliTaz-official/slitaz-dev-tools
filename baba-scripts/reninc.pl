#! /usr/bin/perl
#check for help
chomp (my $workdir = `pwd`);
chomp (my $scriptname=`basename "$0"`);
scalar @ARGV > 0 || die <<EOT1;
Usage : $scriptname [-psdn [argument]] directory|here

Options :
    -p prefix
    -s suffix
    -d starting_base_number
    -n length of number part (1: one number, 2: two numbers, etc)

Parameters :
    directory : complete path of directory to process, or "here" for
                working directory
                ($workdir)
EOT1
#check arguments
my ($pref, $suff, $start, $num_length) = ('', '', 1, 1);
while (scalar @ARGV > 0)
{
	my $arg = shift @ARGV;
	if ($arg eq "-p") { $pref = shift @ARGV; next; }
	elsif ($arg eq "-s") { $suff = shift @ARGV; next; }
	elsif ($arg eq "-d") { $start = shift @ARGV; next; }
	elsif ($arg eq "-n") { $num_length = shift(@ARGV) - 1; next; }
	elsif (-d $arg) { $dir = shift @ARGV; next; }
	elsif ($arg eq "here") { $dir = $workdir; next; }
}
#main routine
chdir $dir;
foreach (<*>)
{
	my $counter = $start;
	my ($purename, $ext) = (m/^(.+?)\.([^\.]+)$/);
	for (my $n = 1; $n <= $num_length; $n++)
	{
		last if ($num_length eq 0);
		if ($start < 10**$n) { $counter = '0'.$counter; }
	}
	$start++;
	print "Rename \"$_\" in $pref$counter$suff.$ext\n";
	rename $_, $pref.$counter.$suff.'.'.$ext;
}
