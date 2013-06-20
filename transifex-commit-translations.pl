#! /usr/bin/perl -w


use File::Basename;
use Git::Wrapper;


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

		# Fix for polish umlaits (Sorry, Michal)
		if ( $user_email eq "gatkowski.michal\@gmail.com" )
		{
		    $user_name = "Michal Gatkowski";
		}
	    }
	}
    }
    close (PO);
}


sub commit_if_necessary
{
    $repodir = dirname($pofile);
    # print "Repo is in " . $repodir . "\n";
    my $git = Git::Wrapper->new($repodir);
    # print "Git wrapper is " . $git . "\n";
    $git->config('user.name',  $user_name);
    $git->config('user.email', $user_email);

    $filename = fileparse($pofile);
    $git->add($filename);

    ($foo, $bar) = split(/\/locale\//, $pofile);
    $message = "locale/" . $bar;
    $message = "Translated " . $message . " on transifex.com";
    # print "Message: '" . $message . "'\n"
    $git->commit({ message => $message });
}



if ($#ARGV > -1)
{
    $pofile = $ARGV[0];
    if ( -e $pofile )
    {
	obtain_translator();

	print $pofile . " - '" . $user_name . "' - '" . $user_email . "'\n";

	commit_if_necessary();
    }
}
