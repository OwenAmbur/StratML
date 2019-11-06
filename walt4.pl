#!/usr/bin/perl
#use cPanelUserConfig;
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use XML::DOM;
use HTTP::Lite;
use strict;

 BEGIN {
 	#print "Content-type: text/html\n\n";
 	my $homedir = ( getpwuid($>) )[7];
 	my @user_include;
    foreach my $path (@INC) {
      if ( -d $homedir . '/perl' . $path ) {
        push @user_include, $homedir . '/perl' . $path;
        }
    }
    unshift @INC, @user_include;
 }

# http://stratml.us/carmel/iso/NTU.xml
# http://stratml.us/carmel/iso/CR4.xml


# XMLFullMerge.
# Read the instance "against" the XML empty tree template.
# The purpose of this script is to build an instance for XForms.
# The template file is used to populate the elements that are missing
# From the relative xpaths.  For example.  If the template has a sub root model of <a><b/><c/></a>,
# all <a> elements in the instance will have at a minimum <b/> and <c/> in addition to
# whatever else is in the instance's <a>.

# Variable naming.  $t variables are instance based and $t variables are template based.
# For example, $troot is the root element of the template file.

my $parser = new XML::DOM::Parser;

my $cgi = new CGI;

# $instanceurl="http://xml.gov/stratml/USITCIRMStratPlan.xml";

Start:

# $instanceurl="http://xml.gov/stratml/drybridge/Rg.xml";

# $xformdoc="../XF2/stratmlxform5.xml";
# $xroot="StrategicPlan";

# http://xml.gov/stratml/FEARMP.xml
my $xmldoc;
if ($cgi->param('url')) {	
  $xmldoc=GetFileFromURL($cgi->param('url'));
} elsif ($cgi->param('f')) {
	my $buffer;
	my $io_handle = $cgi->upload('f');
	while ( my $bytesread = $io_handle->read($buffer,1024) ) {
  	  $xmldoc.=$buffer;
  	}
} else {
	die "No input";
}

#print "Content-type: text/html\n\n$xmldoc";exit();
$xmldoc=~s|stratml:||g;
$xmldoc=~s|<PerformancePlanOrReport [^>]*?>|<StrategicPlan>|;
$xmldoc=~s|</PerformancePlanOrReport>|</StrategicPlan>|;
$xmldoc=~s|<StrategicPlan[^>]*?>|<StrategicPlan>|;
#$xmldoc=~s|</StrategicPlan[^>]*?>|</StrategicPlan>|; # alian
$xmldoc=~s|<Stakeholder>|<Stakeholder StakeholderTypeType="">|g;
$xmldoc=~s|<FirstName>|<GivenName>|g;
$xmldoc=~s|</FirstName>|</GivenName>|g;
$xmldoc=~s|<LastName>|<Surname>|g;
$xmldoc=~s|</LastName>|</Surname>|g;

my $idoc;
eval {
	$idoc = $parser->parse($xmldoc);
}; 
if ($@) {
	print "Content-type: text/xml\n\n";
	print $xmldoc;	
	exit();
}
my $iroot=$idoc->getDocumentElement();
my $xformdoc="../XF2/stratmlisoxform.xml";

# $xroot="StrategicPlan";
my $xroot=$iroot->getNodeName;
if ($xroot eq "StrategicPlan")
	{
	$xformdoc="../XF2/stratmlisoxform.xml";
	}

# elsif ($xroot eq "stratml:StrategicPlan")
#	{
#	$xformdoc="../XF2/stratmlxform4.xml";
#	}

else
	{
	print "Content-type: text/xml\n\n";
	print $xmldoc;
	 #print "<html><body><p>Problem with input XML file</p>";
	 #print "<p>url=".$instanceurl."</body></html>\n";
	exit;

	}	

$xformdoc="Part1Form.xml";
#print "2nd parse\n";
my $tdoc = $parser->parsefile($xformdoc);
my $troot=$tdoc->getDocumentElement();


my @tinf=$troot->getElementsByTagName("xf:instance");

$troot=$tinf[0];
$troot=$troot->getFirstChild;
while ($troot->getNodeName eq "#text")
	{$troot=$troot->getNextSibling;}


$troot->normalize();
$iroot->normalize();

# %thash is a hash of xpath strings that point to the nodes of the first occurence of that xpath in the file.
my %thash;
$thash{$troot->getNodeName}=$troot;

# The result of fillhash is the creation of %tshash
 fillhash($troot,$troot->getNodeName);

UpdateNode($troot,$iroot);
# print $iroot->toString;
#exit;








binmode STDOUT, ":utf8";

open(IN, "<:utf8", $xformdoc);
open(OUT, ">:utf8", "Part1FormImport.xml");

my $docp=$iroot->toString;
# $docp=~s| xmlns="[^"]*?"||;
$docp=~s|<stratml:StrategicPlan xmlns:stratml="http://www.stratml.net">|<stratml:StrategicPlan>|;
$docp=~s|<StrategicPlan[^>]*?>|<StrategicPlan xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stratml="urn:ISO:std:iso:17469:tech:xsd:stratml_core">|;
my $instanceurl = $cgi->param('url');

my $flag=0;
while (<IN>)
	{
	# s| xmlns="[^"]*?"||;
	if (m|</xf:instance>|)
		{$flag=0;}
		
	if ($flag==0)
		{print OUT $_;}
	if (m|<!-- Display URL -->|)
		{
		if ($instanceurl)
			{
			print OUT "<center><a target=\"_blank\" href=\"".$instanceurl."\">".$instanceurl."</a></center>\n";
			}
		}		
	if (m|<xf:instance|)
		{
		$flag=1;
		print OUT $docp;
		}
	}
close(IN);
close(OUT);

print "Content-type: text/html\n\n";
print "<html>";
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=Part1FormImport.xml\"/>\n";

print "<body><p><a href=\"Part1FormImport.xml\">Link</a></p></body>\n";

exit;



#######################################
# GetFileFromURL
#######################################
sub GetFileFromURL {
	my $website=$_[0];
	my $errorstr=$_[1];
	my $http = new HTTP::Lite;
	my $req;
	if (!($req = $http->request($website))) 
		{
		print "Content-type: text/html\n\n";		
		print "<html><title>".$website." not available aa</title>\n";
		print "<body>\n";	
		print "<h2>".$website." is unavailable at this time.</h2>\n";
		print "<p>Here's a link to the government's URL you requested. <a href=\"".$website."\">".$website."</a>";
		print "</body></html>";
		exit;
		}
		
	my $body="";
	$body = $http->body();

	# Text for availability
	if ($errorstr && $body=~m|$errorstr|)
		{
		print "Content-type: text/html\n\n";		
		print "<html><title>".$website." not available</title>\n";
		print "<body>\n";	
		print "<h2>".$website." is unavailable at this time.</h2>\n";
		print "<p>Here's a link to the government's URL you requested. <a href=\"".$website."\">".$website."</a>";
		print "</body></html>";
		exit;
		}

	return($body);	
}

	
	


#######################################
sub fillhash {
#######################################
# fillhash is a recursive function that walks the tree and builds up a hash of xpaths that point to DOM nodes.
# if the DOM node is empty, "" is returned.
# This is very effective for capturing XML content models from XML empty tree files (or XForm instance template).
# These template files are or may be needed when importing an XML file into an XForm so that non-exisitent elements
# in the <xf:instance> container are present.  Their presence produce entry boxes to enter data in the form.

my $node=$_[0];
my $pathbase=$_[1];

if ($node->hasChildNodes)
	{
	my @cnodes=$node->getChildNodes;
	my $ccount=$#cnodes;

	for (my $j=0;$j<$ccount;$j++)
		{
		my $nname=$cnodes[$j]->getNodeName;
		# print "CHILD=".$pathbase."/".$nname."\n";
		if ($nname ne "#text")
			{
			$thash{$pathbase."/".$nname}=$cnodes[$j];
			fillhash($cnodes[$j],$pathbase."/".$nname);
			}		
		}
	}
else
	{
	my $tname=$node->getNodeName;
	# print "NOCHILDREN: ".$pathbase."/".$tname."\n";
	$thash{$pathbase}="";
	}
}






#######################################
sub UpdateNode {
#######################################
# sub UpdateNode($thash{$ipath1},$samels[$u])
my $templatenode=$_[0];
my $instancenode=$_[1];
my @tnodes;
my @inodes;
my $inode;
my $newel;
my %itemp=undef;
# my $inode;
# print "UPDATENODE\n";
# print $templatenode->toString;
if ($templatenode->hasChildNodes)
	{
	my @tnodes1=$templatenode->getChildNodes;
	my $tnodecnt1=$#tnodes1;
	# print "template node count=".$tnodecnt1."\n";
	my $s=0;
	for (my $t=0;$t<=$tnodecnt1;$t++)
		{
		if ($tnodes1[$t]->getNodeName ne "#text")
			{
			$tnodes[$s]=$tnodes1[$t];
			$s++;
			}
		}
	my $tnodecnt=$s-1;
	# print "TNC=".$tnodecnt."\n";
	# print "INODE=".$instancenode->getNodeName."\n";
	
	if ($instancenode->hasChildNodes)
		{
		my @inodes1=$instancenode->getChildNodes;
		my $inodecnt1=$#inodes1;

		my $s=0;
		for (my $t=0;$t<=$inodecnt1;$t++)
			{
			if ($inodes1[$t]->getNodeName ne "#text")
				{
				$inodes[$s]=$inodes1[$t];
				$s++;
				}
			}
		my $inodecnt=$s-1;

		# setup hash for instance
		for (my $j=$inodecnt;$j>=0;$j--)
			{
			# print $inodes[$j]->getNodeName." ";
			$itemp{$inodes[$j]->getNodeName}=$inodes[$j];
			}
		# print "\n";
		# print "ITEMP Created ".$tnodecnt."\n";
		my $k=0;
#		
# Reverse order
		for (my $j=$tnodecnt;$j>=0;$j--)
	#	for (my $j=0;$j<=$tnodecnt;$j++)
			{
			my $tName=$tnodes[$j]->getNodeName;
			# if the element from the template isn't in the instance.
			 # print "UZ=".$tName."\n";

			if (!$itemp{$tName})
				{
				my $newel=$idoc->createElement($tName);
				if ($j==$tnodecnt)  
					{
					# print "AC ".$j." ".$tName."\n";
					$inode=$instancenode->appendChild($newel); 	
					$itemp{$tName}=$inode;
					}
				
				else 
					{
					# print "AC ".$j." ".$tName;
					my $nextname=$tnodes[$j+1]->getNodeName;
					# print " NN=".$nextname."\n";
					$inode=$instancenode->insertBefore($newel,$itemp{$nextname});
					$itemp{$tName}=$inode;
					}
					

				# print "appended=".$tName."\n";
				# print $tnodes[$j]->toString."\n\n";
				 if ($tnodes[$j]->hasChildNodes)
					{
					# "***** Recursive call to update\n";
					# print "UPDATENODE 2 ".$tName." ".$inode->getNodeName."\n";
					UpdateNode($tnodes[$j],$inode);
					}

				}
			# The node exists in the template and the instance.
			else
				{
				# for (my $m=0;$m<=$inodecnt;$m++)
				# Reversed Update.
				for (my $m=$inodecnt;$m>=0;$m--)
					{
					if ($inodes[$m]->getNodeName eq $tName)
						{
						# print "UPDATENODE 3 ".$tName."\n";
						UpdateNode($tnodes[$j],$inodes[$m]);
						}
					}
				}
			}
		
		}

	# Template exists, but the instance node has no children.
	else
		{
		# print "Instance ".$instancenode->getNodeName." has no children\n";
		my $k=0;
		for (my $j=0;$j<=$tnodecnt;$j++)
			{
			my $tName=$tnodes[$j]->getNodeName;

			# if the element from the template isn't in the instance.
			if (!$itemp{$tName})
				{
				$newel=$idoc->createElement($tName);

				$inode=$instancenode->appendChild($newel); 	
				# print "TNAME APP=".$tName."\n";
				$itemp{$tName}=$inode;

				if ($tnodes[$j]->hasChildNodes)
					{
					UpdateNode($tnodes[$j],$inode);
					}
				}
			}

		}

	}


}