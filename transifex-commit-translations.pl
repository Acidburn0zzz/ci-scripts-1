#! /usr/bin/perl -w


our $pofile;

our $user_name  = "Hakan Tandogan";
our $user_email = "hakan\@gurkensalat.com";


sub obtain_translator
{
    # Fallback just in case we can't find anything...
    $user_name  = "Transifex Daemon";
    $user_email = "transifex-daemon\@gurkensalat.com";

    open (PO, "< $pofile") || die ("Can't open $pofile to read: $!");
    while (<PO>)
    {
	if (/^\"Last-Translator\:\s/)
	{
	    chomp;
	    # print "'" . $_ . "'\n";
	    $_ =~ s/^\"Last-Translator\:\s//;
	    $_ =~ s/\\n\"//;
	    # print "'" . $_ . "'\n";

	    @foo = split(/[\<\>]/, $_);
	    # print "'" . join("', '", @foo) . "'\n";
	    if ($#foo > 0)
	    {
		$user_name = $foo[0];
		$user_name =~ s/\s+$//g;

		$user_email = $foo[1];
	    }
	}
    }
    close (PO);
}



if ($#ARGV > -1)
{
    $pofile = $ARGV[0];
    if ( -e $pofile )
    {
	obtain_translator();

	print $pofile . " - '" . $user_name . "' - '" . $user_email . "'\n";
    }
}
