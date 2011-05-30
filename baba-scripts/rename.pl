#! /usr/bin/perl
$testmode = 0;  #false
if ($ARGV[0] eq '-t') {
   $testmode = 1;  #true
   shift;
}
($regexp = shift @ARGV) || die "Usage:  rename [-t] perlexpr [filenames]\n-t : option to test action (nothing really done)\n";
if (!@ARGV) {
   @ARGV = <STDIN>;
   chomp(@ARGV);
}
print "Test mode\n" if ($testmode);
foreach $_ (@ARGV) {
   $old_name = $_;
   eval $regexp;
   die $@ if $@;
   unless ($old_name eq $_) {
	   print "$old_name -> $_\n";
	   rename($old_name, $_) unless $testmode;
   }
}
exit(0);
