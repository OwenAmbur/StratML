#######################################
# 2012/12/17 - BreakDown.
# This program is used to extract information from a series of
# web files.
# Steps.
# 1. Read in a file/URL with URLs to retrieve
# 2. Retrieve each of the URLs/files and store the needed info in the output.
#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
# my $listfile="http://xml.fido.gov/stratml/drybridge/urls.xml";
# my $listfile="http://stratml.us/StratMLSiteMap.xml";
my $listfile="https://stratml.us/sitemap.xml";
# my $listsearch="<etgov:WebAddress>([^<]*?)<";
my $listsearch="<loc>([^<]*?)<";
my $namesearch="[<:]Name>([^<]*?)<";
my $orgsearch="<Organization>\\s*<Name>([^<]*?)<";
my $nsorgsearch="<stratml:Organization>\\s*<stratml:Name>([^<]*?)<";
my $pubdatesearch="[<:]PublicationDate>([^<]*?)<";
my $sourcesearch="[<:]Source>\\s*([^<]*?)<";
my $outputhtml="catalogsitemap.html";
my $controlfile="control.txt";
my %URL;
my %URLNames;
my @nocontentfiles;
my $nocontentcount=0;
my $lasttime="";
my $now=GetNow();
# Check a control file first.
if (-e $controlfile)
	{
	print "Content-type: text/html\n\n";
	print "<html><body>StratML Catalog Analysis in Process.  Please wait.</body></html>.";
	exit;
	}
my $ocontrolfile=">".$controlfile;
open(CONTROL,$ocontrolfile);
print CONTROL $now;
close(CONTROL);
$now=~m|T([^-]*?)-|;
my $t1 = $1;
# Get the contents of the main file that contains the list of files to retrieve.
my $listfilecontent;
if ($listfile=~m|^http|)
	{
	$listfilecontent=CurlGet($listfile) or die 'Unable to get listfile ' & $listfile;
	}
my $fcount=0;	
my $totalfcount=0;	
my $percentdone=0;
$totalfcount++ while ($listfilecontent =~ /$listsearch/g);
	
	
# Using the $listsearch variable, get the URL for each file to retrieve.
while ($listfilecontent=~s|$listsearch||)
	{
	my $f=$1;
	$fcount++;
	print $f."\n";
	my $inputfilecontent;
	if (!($inputfilecontent=CurlGet($f))) 
		{
		$nocontentfiles[$nocontentcount]=$f;
		$nocontentcount++;		
		goto GetNextFile;
		}
		
	# Separately (for StratML in particular), establish a hash of URLs for <Name> using the $namesearch variable
	if ($inputfilecontent=~m|$namesearch|)
		{
		my $name=$1;
		# if FACA, get next Name element
		if ($name=~m|^FACA |)
			{
			$inputfilecontent=~s|Name>||;
			$inputfilecontent=~s|Name>||;
			if ($inputfilecontent=~m|$namesearch|)
				{
				$name=$1;
				$name="FACA ".$name;
				}
			}
		my $org="";	
		if ($inputfilecontent=~m|$orgsearch|)
		    {
		    $org=$1;
		    }
		elsif ($inputfilecontent=~m|$nsorgsearch|)
			{
			$org=$1;
			}   
			
		my $pubdate="";	
	    if ($inputfilecontent=~m|$pubdatesearch|)
	        {
	        $pubdate=$1;
	        } 
	        
	        
        if (length($org)>0)
            {
            if (length($pubdate)>0)
                {
		    	$URLNames{$f}=$pubdate." - <b>".$org."</b>: ".$name;
		    	}
		    else
                {
		    	$URLNames{$f}="<b>".$org."</b>: ".$name;
		    	}
		    
		    }
		else
            {
            if (length($pubdate)>0)
                {$URLNames{$f}=$pubdate." - ".$name;}
            else
            	{$URLNames{$f}=$name;}
		    }
		
		# print "URLNAME=".$name."\n";
		}
	
	
	# For StratML, retrieve the <Source> element and break out the domain using SortURLString 
	# (e.g., gov house www).  %URL hash is created to store all associated $f.  Separated by @.
	if ($inputfilecontent=~m|$sourcesearch|)
		{
		my $source=$1;
		my $sortstr=SortURLString($source);
# 		print $sortstr."\n";
		if (!$URL{$sortstr})
			{
			$URL{$sortstr}=$f." @ ";
			}
		else
			{
			$URL{$sortstr}=$URL{$sortstr}.$f." @ ";
			}
		
		}
	else
		{
#		print "\n";
		}
	GetNextFile:
	$percentdone=int(($fcount*1000)/$totalfcount);
	# print "Pdone: ".$percentdone."\n";
	if ($percentdone % 20 == 0)
		{
		my $percent=$percentdone/10 ;
		# print "Percent done: ".$fcount." ".$totalfcount." ".$percent."\%<br/>\n";
		open(PROGRESS,">progress.txt");
		print PROGRESS $percent;
		close(PROGRESS);
		
		}
		
	if (0) # $fcount==501) 
		{
		open(PROGRESS,">progress.txt");
		print PROGRESS "100";
		close(PROGRESS);
                goto Keys;
                }		
	
	print "\nCOUNT=".$fcount."\n";	
	# if ($fcount==101) {goto Keys;}		
	}
	
Keys:
my $key;
my $outfile=">".$outputhtml;
open(OUT,$outfile);
print OUT "<html>";
print OUT "<head><title>StratML Files By Source Domains</title>\n";
print OUT "<style>\n";
print OUT "li {margin-left:20px;}\n";
print OUT "</style>\n";
print OUT "</head>\n";
print OUT "<body>";
print OUT "<center><h1>StratML Files Organized by Source Domains</h1></center>\n";
print "Content-type: text/html\n\n";
print "<html>";
print "<head><title>StratML Files By Domain Processing Results</title>\n";
print "<style>\n";
print "li {margin-left:20px;}\n";
print "</style>\n";
print "</head>\n";
print "<body>";
print "<h1>StratML Files By Domain Processing Results</h1>";
print "<p><b>Process Started:</b> ". $now."<br/>\n";
print OUT "<p><b>Process Started:</b> ". $now."<br/>\n";
my $fcountshow=$fcount-1;
print "<b>Files Processed:</b> ".$fcountshow."<br/>\n";
print OUT "<b>Files Processed:</b> ".$fcountshow."<br/>\n";
print "<b>Files with no content:</b> ".$nocontentcount."<br/>\n";
print OUT "<b>Files with no content:</b> ".$nocontentcount."<br/>\n";
my $nosourcecount = 0;
if (length($URL{""})>0)
	{
	$nosourcecount++ while ($URL{""} =~ /@/g);
	print "<b>Files with no &lt;Source&gt;:</b> ".$nosourcecount."<br/>\n";
	print OUT "<b>Files with no &lt;Source&gt;:</b> ".$nosourcecount."<br/>\n";		
	}
my $goodfiles=$fcountshow-$nocontentcount-$nosourcecount;
print "<b>Total Files Below:</b> ".$goodfiles."<br/>\n";
$now=GetNow();
$now=~m|T([^-]*?)-|;
my $t2 = $1;
print "<b>Finished Processing:</b> ".$now."<br/>\n";
print OUT "<b>Finished Processing:</b> ".$now."<br/>\n";
print "<b>Time Elapsed:</b> ";
print OUT "<b>Time Elapsed:</b> ";
my $t3=to_milli($t2) - to_milli($t1);
print $t3." seconds<br/>\n";
print OUT $t3." seconds<br/>\n";
print "<b>Output file for public users:</b> ".$outputhtml."<br/>\n";
print "<br/>If you're reading this, you have just processed the StratML files in the list located at ";
print "<a href=\"".$listfile."\">".$listfile."</a>.  This processing updates the output results at ";
print "<a href=\"".$outputhtml."\">".$outputhtml."</a> which can be then used to ";
print " browse for similar StratML files without taking the time to process all of the data again.<br/>\n";
print "<br/>";
print "The processing of the files you just used took some time to accomplish (".$t3." seconds).  This ";
print "processing time only needs to occur when there are changes to the ".$outputhtml." list or those files. ";
print "Whenever you add or change the StratML ";
print "files, please re-execute this software.  Some of the information below (i.e., the missing files and the files that do not have a Source) ";
print "is not provided at ".$outputhtml."\n";
if ($nocontentcount>0) 
	{
	print "<h2>FILES NOT FOUND</h2>\n<p><ul>";
	print OUT "<h2>FILES NOT FOUND</h2>\n<p><ul>";	
	for (my $j=0;$j<$nocontentcount;$j++)
		{
		print "<li><a href=\"".$nocontentfiles[$j]."\">".$nocontentfiles[$j]."</a></li>\n";
		print OUT "<li><a href=\"".$nocontentfiles[$j]."\">".$nocontentfiles[$j]."</a></li>\n";		
		}
	print "</ul></p>\n\n";
	print OUT "</ul></p>\n\n";	
	}
# foreach $key (sort keys %URLNames) {
# print $key."\t".$URLNames{$key}."\n";
# }
# exit;
my $tablecount=0;
my $key1="";
print OUT "<p><b>Number of StratML Files:</b> ".$goodfiles."<br/>\n";
print OUT "<b>Last Processed:</b> ".$now."<br/></p>\n";
# print "URL of nothing=".$URL{""}."<br>\n";
# StratML FILES WITH NO SOURCE SPECIFIED
if (length($URL{""})>0)
	{
	print "<h2>StratML FILES WITH NO SOURCE SPECIFIED</h2>";
	print OUT "<h2>StratML FILES WITH NO SOURCE SPECIFIED</h2>";	
	my $nosourcefiles=$URL{""};
	$nosourcefiles=~s|\@|</li><li>|g;
	$nosourcefiles=~s|<li>\s*$||;
	$nosourcefiles="<li>".$nosourcefiles;
	$nosourcefiles=~s|<li>([^<]*?)<|<li><a href="$1">$1</a><|g;
	print "<ul><table><tr><td>";
	print OUT "<ul><table><tr><td>";	
	print "<p>".$nosourcefiles."</p>\n";
	print OUT "<p>".$nosourcefiles."</p>\n";	
	print "</td></tr></table></ul>";
	print OUT "</td></tr></table></ul>";	
	}
print "<h1>StratML File List by Source Domains<h1>\n";
print OUT "<h1>StratML File List by Source Domains<h1><script src=\"/forms2/fixurlaccess.js\"></script>\n";
foreach my $key (sort keys %URL) {
	# print "key=".$key."\n";
	# print OUT "key=".$key."\n";
	# StratML FILES WITH NO SOURCE SPECIFIED
	if ($key!~m| |)
		{
		# print "<h2>StratML FILES WITH NO SOUCE SPECIFIED</h2>";
		# my $nosourcefiles=$URL{$key};
		# $nosourcefiles=~s|\@|</li><li>|g;
		# $nosourcefiles=~s|<li>\s*$|g;
		# print "<table><tr><td>";
		# print "<p><li>".$nosourcefiles."</p>\n";
		# print "</td></tr></table>";
		}
	
	else
		{
		
		my @us=split(/ /,$key);
	
		if ($us[0] ne $key1)
			{
			$key1=$us[0];
			if ($tablecount>0)
				{
				print OUT "</table></ul>\n";
				print "</table></ul>\n";
				}
			$tablecount++;		
			print "<h1>.".$key1."</h1>\n";	
			print "<ul><table border=\"1\">";
			print OUT "<h1>.".$key1."</h1>\n";	
			print OUT "<ul><table border=\"1\">";
		
			}
	
		my @forward = reverse(@us);
		my $origurl=join(".",@forward);
	
	
		print "<tr><td>".$origurl."</td><td>";
		print OUT "<tr><td>".$origurl."</td><td>";
	
		while($URL{$key}=~s|^([^@]*?)@||)
			{
			my $u=$1;
			$u=~s|^\s*||;
			$u=~s|\s*\@$||;
			$u=~s|\s*$||;
			# print "\n\t".$URLNames{$u};
	
			my $uname=$URLNames{$u};
			# $u=~s|\.xml|wStyle.xml|;
			# print "\n\t(";
			print "<li><a href=\"".$u."\">".$uname."</a></li>";

			print OUT "<li><a href=\"".$u."\">".$uname."</a> - <a  href=\"#\" onclick=\"postDataUrl('".$u."')\">EDIT</a></li>";	
			# print $uname;
			# print ")\n";
		   	#  print "$key: $URL{$key}\n";
		   	}	   	
	   	}
	   	
	print "\n";	
	print "</td></tr>";
	print OUT "\n";
	print OUT "</td></tr>";
	
}
	
print "</table></html>";
print OUT "</table></html>";
close(OUT);
unlink($controlfile);
exit 0;
#######################################
sub SortURLString 
#######################################
{
my $url=shift;
my $url1="";
my $url2="";
my $url3="";
my $url4="";
my $url5="";
my $url6="";
my $url7="";
$url=~s|^http[s]?://([^/]*?)/||;
my $urlmain=$1;
if ($urlmain=~m|^([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	$url3=$3;
	$url4=$4;
	$url5=$5;
	$url6=$6;	
	$url7=$7;	
	return($url7." ".$url6." ".$url5." ".$url4." ".$url3." ".$url2." ".$url1);	
	}
elsif ($urlmain=~m|^([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	$url3=$3;
	$url4=$4;
	$url5=$5;
	$url6=$6;	
	return($url6." ".$url5." ".$url4." ".$url3." ".$url2." ".$url1);	
	}
elsif ($urlmain=~m|^([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	$url3=$3;
	$url4=$4;
	$url5=$5;
	return($url5." ".$url4." ".$url3." ".$url2." ".$url1);	
	}
elsif ($urlmain=~m|^([^\.]*?)\.([^\.]*?)\.([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	$url3=$3;
	$url4=$4;
	return($url4." ".$url3." ".$url2." ".$url1);	
	}
elsif ($urlmain=~m|^([^\.]*?)\.([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	$url3=$3;
	return($url3." ".$url2." ".$url1);	
	}
elsif ($urlmain=~m|^([^\.]*?)\.([^/]*?)$|)
	{	
	$url1=$1;
	$url2=$2;
	return($url2." ".$url1);	
	}
	
# print $url."\n";
# print $url3." ".$url2." ".$url1."\n";
return("");
}
#######################################
sub GetNow {
#######################################
GetTime:
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
$year=$year+1900;
$mon=$mon+1;
my $today=sprintf("%4d-%02d-%02d",$year,$mon,$mday);
my $time=sprintf("%02d:%02d:%02d-05:00",$hour,$min,$sec);
my $otime=$time;
my $secfactor;
if ($time eq $lasttime)
	{
	if ($sec <59-$secfactor)
		{
		my $newsec=sprintf("%02d",$sec+$secfactor);
		$time=~s|(\d\d)\-05:00$|$newsec-05:00|;
		
		$secfactor++;
		}
		
	else
	
		{goto GetTime;}
	
	}
$lasttime=$otime;
$now=$today."T".$time;
return $now;
}
#######################################
sub to_milli {
#######################################
    my @components = split /[:\.]/, shift;
    return (($components[0] * 60) + ($components[1] * 60) + $components[2]) ;
}


#######################################
sub CurlGet {
#######################################
my $f=$_[0];
my $filename="temp.out";

# print "IN GETCURL -".$f."\n";
system "curl ".$f." >".$filename;

# X:
# if (-e $filename) {
# print "File Exists!";
# }
# else {goto X;}

open my $fh, 'temp.out' or die "Can't open file $!";

# my $file_content = do{local(@ARGV,$/)=$fh;<>};
read $fh, my $file_content, -s $fh;

return($file_content);
}
