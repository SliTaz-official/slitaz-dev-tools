#! /usr/bin/perl -w
chomp (my $scriptname = `basename "$0"`);
chomp (my $workdir = `pwd`);
my $help = <<HELP;
Usage : $scriptname -h
        $scriptname [-t] [work-directory]
HELP
my $testmode = 0;
my $prefix = "";
#check dependencies
die "Execution error: rename.pl needed but not found\n" if (`which rename.pl` eq '');
#check parameters
die $help if ($ARGV[0] eq '-h' or $ARGV[0] eq '--help');
foreach my $a (@ARGV)
{
	if ($a eq '-t') { $testmode = 1; }
	else
	{
		$a = $workdir.'/'.$a if ($a !~ /^\//);
		if(-d $a and -r $a) { $workdir = $a; }
		else { die "Syntax error: $a is not a valid directory\n$help"; }
	}
}
#asks a pattern for rename.pl if unknown
if ($prefix eq '')
{
	print "*** CAUTION: no prefix specified in substitution pattern for rename.pl\n";
	print "*** Please fill in a prefix once for the whole process\n";
	print "*** (press ENTER key to validate) : ";
	chomp ($prefix = <STDIN>);
}
#look for subdirectories in $workdir
print "Scanning subdirectories in $workdir...\n";
chdir $workdir;
foreach $f (<*>)
{
	my $path = $workdir.'/'.$f;
	if (-d $path)
	{
		chdir $path;
		my @all = <*>;
		my @regularfiles = grep { -f } @all;
		printf "\n> %s : %d files\n", $f, scalar @regularfiles;
		next if (scalar @regularfiles == 0);  #skip if empty
		#parse numeric part of $path to use in rename.pl's pattern
		$path =~ /(\d+)/;
		my $num = $1;
		system 'rename.pl '.($testmode == 1? '-t ':'').'"s/^/'.$prefix.$num.'_/" *';  #call rename.pl
		#update files data (changed because of renaming)
		@all = <*>;
		@regularfiles = grep { -f } @all;
		#~ print join ("\n", @regularfiles), "\n";
		map { rename $_, $workdir.'/'.$_ } @regularfiles unless ($testmode);  #move files one level up
		#check for subdirectory inside
		if (scalar (grep { -d } @all) > 0) { warn "Caution: subdirectory found in $f => not deleted\n"; next; }
		chdir $workdir;
		unless ($testmode) { rmdir $path or die "$!\n"; }
	}
}
