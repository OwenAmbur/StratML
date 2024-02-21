#!/usr/bin/perl
use cPanelUserConfig;
#print "Content-Type: text/html\n\n";

# XMLFullMerge.
# Read the instance "against" the XML empty tree template.
# The purpose of this script is to build an instance for XForms.
# The template file is used to populate the elements that are missing
# From the relative xpaths.  For example.  If the template has a sub root model of <a><b/><c/></a>,
# all <a> elements in the instance will have at a minimum <b/> and <c/> in addition to
# whatever else is in the instance's <a>.

# Variable naming.  $t variables are instance based and $t variables are template based.
# For example, $troot is the root element of the template file.

use XML::DOM;
my $parser = new XML::DOM::Parser;

use HTTP::Lite;
$http = new HTTP::Lite;

use Data::UUID;
$ug = new Data::UUID; 

# goto Start;

$OK_CHARS='-a-zA-Z0-9_.:\\/@';	# A restrictive list, which
				# should be modified to match
				# an appropriate RFC, for example. from 
				# http://www.cert.org/tech_tips/cgi_metacharacters.html




if ($content_length = $ENV{'CONTENT_LENGTH'})
	{
	
	read (STDIN, $posted_information, $content_length);


	#gather Variables from STDIN
	#Decoding the Data

	$posted_information =~ s/\+/" "/eg;
	$posted_information =~ s/\%20/" "/eg;

	$posted_information =~ s/\%3A/":"/eg;
	$posted_information =~ s/\%2F/"\/"/eg;


	#Splitting into Variables
	(@fields) = split (/&/, $posted_information);
	for (my $m=0;$m<$#fields;$m++)
		{
		($variable, $varx) = split (/=/, $fields[$m]);
		if ($variable=~m|^url$|)
			{
			$instanceurl=$varx;
			}
		}

	}
else
	{
			
	$posted_information=$ENV{QUERY_STRING};
	$posted_information =~ s/\%3A/":"/eg;
	$posted_information =~ s/\%2F/"\/"/eg;
	(@fields) = split (/&/, $posted_information);
	

	for (my $m=0;$m<=$#fields;$m++)
		{
		($variable, $varx) = split (/=/, $fields[$m]);
		if ($variable=~m|^url$|)
			{
			$instanceurl=$varx;
			}
		}
	
	
	}
	
# $instanceurl="http://xml.gov/stratml/USITCIRMStratPlan.xml";

$posted_information=~s|\n| |g;
$posted_information=~s|<.xml-stylesheet [^>]*?>||;
if ($posted_information=~m|\?\s*>\s*(.*)|)
	{
	$fcontents=$1;
	$fcontents=~m|^<([^\?][^ >]*?)[ >]|;
	my $r=$1;
	$fcontents=~s|</($r)\s*>.*|</\1>|;
	
	}

Start:



# $instanceurl="http://xml.gov/stratml/drybridge/Rg.xml";

# $xformdoc="../XF2/stratmlxform5.xml";
# $xroot="StrategicPlan";

# http://xml.gov/stratml/FEARMP.xml

if (!$fcontents)
	{
	$xmldoc=GetFileFromURL($instanceurl);
	}
else
	{
	$xmldoc=$fcontents;
	}
$xmldoc=~s|stratml:||g;
$xmldoc=~s|<.xml-stylesheet type="text/xsl" href="stratml.xsl".>||;

$xmldoc=~s! xmlns="[^"]*?" ! !;

if ($xmldoc=~m|<StrategicPlan |)
    {$StratPlanFlag=1;}


# $xmldoc=~s|<StrategicPlan[^>]*?>|<PerformancePlanOrReport xmlns="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport" xmlns:xsi="http://www.w3.org/2001/XMLSchema-
# instance" xsi:schemaLocation="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport http://xml.fido.gov/stratml/references/PerformancePlanOrReportISOVersion20150612.xsd" 
#Type="Strategic_Plan">|;

# $xmldoc=~s| xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stratml="urn:ISO:std:iso:17469:tech:xsd:stratml_core||;


# 2015/10/7
$xmldoc=~s|<.xml-stylesheet [^>]*?>||;
$xmldoc=~s|www.xml.fido.gov|xml.fido.gov|g;

$xmldoc=~s|<StrategicPlan [^>]*?>|<PerformancePlanOrReport Type="Strategic_Plan"><id></id>|;
$xmldoc=~s|<StrategicPlan>|<PerformancePlanOrReport Type="Strategic_Plan"><id></id>|;

$xmldoc=~s|xmlns="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport http://xml.fido.gov/stratml/references/PerformancePlanOrReportISOVersion20150612.xsd"||;


$xmldoc=~s|</StrategicPlan>|</PerformancePlanOrReport>|;
$xmldoc=~s|<Stakeholder>|<Stakeholder StakeholderTypeType="">|g;
$xmldoc=~s|<FirstName>|<GivenName>|g;
$xmldoc=~s|</FirstName>|</GivenName>|g;
$xmldoc=~s|<LastName>|<Surname>|g;
$xmldoc=~s|</LastName>|</Surname>|g;



# $xmldoc=~s|> \s+<|><|g;


if ($xmldoc=~s|<Submitter>(.*?)</Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter>\1</Submitter>|)
	{
	$submitter=$1;
	}



# 2015/09/17 - extract submitter for placement after Administrative Information 
# if ($StratPlanFlag==1)
 #    {
     # all
#     if ($xmldoc=~s|<Submitter><GivenName>([^<]*?)</GivenName><Surname>([^<]*?)</Surname><EmailAddress>([^<]*?)</EmailAddress></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName>\1</GivenName><Surname>\2</Surname><EmailAddress>\3</EmailAddress></Submitter>|) {}
     # no givenname
#     elsif ($xmldoc=~s|<Submitter><GivenName/><Surname>([^<]*?)</Surname><EmailAddress>([^<]*?)</EmailAddress></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName></GivenName><Surname>\1</Surname><EmailAddress>\2</EmailAddress></Submitter>|) {}
     # no surname
#     if ($xmldoc=~s|<Submitter><GivenName>([^<]*?)</GivenName><Surname/><EmailAddress>([^<]*?)</EmailAddress></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName>\1</GivenName><Surname></Surname><EmailAddress>\3</EmailAddress></Submitter>|) {}
     # no email
#     elsif ($xmldoc=~s|<Submitter><GivenName>([^<]*?)</GivenName><Surname>([^<]*?)</Surname><EmailAddress/></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName>\1</GivenName><Surname>\2</Surname><EmailAddress/></Submitter>|) {}
     # email only
#     elsif ($xmldoc=~s|<Submitter><GivenName/><Surname/><EmailAddress>([^<]*?)</EmailAddress></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName></GivenName><Surname></Surname><EmailAddress>\1</EmailAddress></Submitter>|) {}
     # Surname only
#     elsif ($xmldoc=~s|<Submitter><GivenName/><Surname>([^<]*?)</Surname><EmailAddress/></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName></GivenName><Surname>\1</Surname><EmailAddress/></Submitter>|) {}
     # given name only?
#     elsif ($xmldoc=~s|<Submitter><GivenName>([^<]*?)</GivenName><Surname/><EmailAddress/></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName>\1</GivenName><Surname/><EmailAddress/></Submitter>|) {}
     # nothing
#     elsif ($xmldoc=~s|<Submitter><GivenName/><Surname/><EmailAddress/></Submitter>\s*</AdministrativeInformation>|</AdministrativeInformation><Submitter><GivenName/><Surname/><EmailAddress/></Submitter>|) {}
#     }

# $xmldoc=~s|<NumberOfUnits/>|<NumberOfUnits>0.0</NumberOfUnits>|g;
# $xmldoc=~s|<NumberOfUnits></NumberOfUnits>|<NumberOfUnits>0.0</NumberOfUnits>|g;

# commented out 9/26
# $xmldoc=~s|<Description></Description>|<Description>[To be described]</Description>|g;
# $xmldoc=~s|<Description/>|<Description>[To be described]</Description>|g;

# $xmldoc=~s|<Name></Name>|<Name>[To be named]</Name>|g;
# $xmldoc=~s|<Name/>|<Name>[To be named]</Name>|g;



$xmldoc=~s|<Relationship>(\s*)<Identifier></Identifier>|<Relationship>\1<Identifier>[To be identified]</Identifier>|g;
$xmldoc=~s|<Relationship RelationshipType="">(\s*)<Identifier></Identifier>|<Relationship>\1<Identifier>[To be identified]</Identifier>|g;
$xmldoc=~s|<Relationship>(\s*)<Identifier/>|<Relationship>\1<Identifier>[To be identified]</Identifier>|g;
$xmldoc=~s|<Relationship RelationshipType="">(\s*)<Identifier/>|<Relationship>\1<Identifier>[To be identified]</Identifier>|g;



$xmldoc=~s|<PerformancePlanOrReport  |<PerformancePlanOrReport |;

# $xmldoc=~s|<PerformancePlanOrReport([^>]*?>)|<PerformancePlanOrReport\1<id>$instanceurl</id>|;

# missing PerformanceIndicatorType
$xmldoc=~s|<PerformanceIndicator ValueChainStage="([^"]*?)"\s*>|<PerformanceIndicator ValueChainStage="\1" PerformanceIndicatorType="">|g;
# missing ValueChainStage
$xmldoc=~s|<PerformanceIndicator PerformanceIndicatorType="([^"]*?)"\s*>|<PerformanceIndicator ValueChainStage="" PerformanceIndicatorType="\1">|g;
# both attributes are missing
$xmldoc=~s|<PerformanceIndicator>|<PerformanceIndicator ValueChainStage="" PerformanceIndicatorType="">|g;

$xmldoc=~s| IndicatorType="[^"]*?"||g;

$idoc = $parser->parse($xmldoc);

$iroot=$idoc->getDocumentElement();

$xroot=$iroot->getNodeName;







# $xformdoc="../XF2/stratmlisoxform.xml";
$xformdoc="Part2Form.xml";

# $xroot="StrategicPlan";
$xroot=$iroot->getNodeName;


# if ($xroot eq "StrategicPlan")
# if ($xroot eq "PerformancePlanOrReport")
#	{
#	# $xformdoc="../XF2/stratmlisoxform.xml";
#       $xformdoc="../StratML/Part2Formud.xml";
#	}


# print "Content-type: text/xml\n\n";
# print $xmldoc;
# exit;





# elsif ($xroot eq "stratml:StrategicPlan")
#	{
#	$xformdoc="../XF2/stratmlxform4.xml";
#	}

# else
if ($xroot!~m@StrategicPlan@ && $xroot!~m@PerformancePlanOrReport@)
	{
	print "Content-type: text/html\n\n";
	print "<html><body><p>Problem with input XML file</p>";
	print "<p>url=".$instanceurl."</body></html>\n";
	exit;
	}	


$tdoc = $parser->parsefile($xformdoc);
$troot=$tdoc->getDocumentElement();




@tinf=$troot->getElementsByTagName("xf:instance");

$troot=$tinf[0];
$troot=$troot->getFirstChild;
while ($troot->getNodeName eq "#text")
	{$troot=$troot->getNextSibling;}


$troot->normalize();
$iroot->normalize();

# %thash is a hash of xpath strings that point to the nodes of the first occurence of that xpath in the file.
undef %thash;
$thash{$troot->getNodeName}=$troot;

# The result of fillhash is the creation of %tshash
 fillhash($troot,$troot->getNodeName);

UpdateNode($troot,$iroot);
# print $iroot->toString;
#exit;








binmode STDOUT, ":utf8";

open(IN, "<:utf8", $xformdoc);
open(OUT, ">:utf8", "StratML/out.xml");

$docp=$iroot->toString;
# $docp=~s| xmlns="[^"]*?"||;
$docp=~s|<stratml:StrategicPlan xmlns:stratml="http://www.stratml.net">|<stratml:StrategicPlan>|;



# $docp=~s|<NumberOfUnits/>|<NumberOfUnits>0.0</NumberOfUnits>|g;
# $docp=~s|<NumberOfUnits></NumberOfUnits>|<NumberOfUnits>0.0</NumberOfUnits>|g;


$docp=~s|<Goal>\s*<Description></Description>|<Goal><Description>[To be described]</Description>|g;
$docp=~s|<Goal>\s*<Description/>|<Goal><Description>[To be described]</Description>|g;


$docp=~s|<TargetResult>\s*<Description></Description>|<TargetResult><Description>[To be described]</Description>|g;
$docp=~s|<TargetResult>\s*<Description/>|<TargetResult><Description>[To be described]</Description>|g;

$docp=~s|<ActualResult>\s*<Description></Description>|<ActualResult><Description>[To be determined]</Description>|g;
$docp=~s|<ActualResult>\s*<Description/>|<ActualResult><Description>[To be determined]</Description>|g;


$docp=~s|<Role>\s*<Name></Name>|<Role><Name>[To be named]</Name>|g;
$docp=~s|<Role>\s*<Name/>|<Role><Name>[To be named]</Name>|g;

$docp=~s|<Goal>\s*<Name>\s*([^<]*?)</Name><Description></Description>|<Goal><Name>\1</Name><Description>[To be described]</Description>|g;
$docp=~s|<Goal>\s*<Name>\s*([^<]*?)</Name><Description/>|<Goal><Name>\1</Name><Description>[To be described]</Description>|g;

$docp=~s|<Goal>\s*<Name></Name><Description></Description>|<Goal><Name>[To be named]</Name><Description>[To be described]</Description>|g;
$docp=~s|<Goal>\s*<Name></Name><Description/>|<Goal><Name>[To be named]</Name><Description>[To be described]</Description>|g;
$docp=~s|<Goal>\s*<Name/><Description/>|<Goal><Name>[To be named]</Name><Description>[To be described]</Description>|g;
$docp=~s|<Goal>\s*<Name/>|<Goal><Name>[To be named]</Name>|g;

$docp=~s|<Stakeholder([^>]*?)>\s*<Name></Name>|<Stakeholder\1><Name>[To be named]</Name>|g;
$docp=~s|<Stakeholder([^>]*?)>\s*<Name/>|<Stakeholder\1><Name>[To be named]</Name>|g;

# $docp=~s|<Name></Name>|<Name>[To be named]</Name>|g;
# $docp=~s|<Name/>|<Name>[To be named]</Name>|g;


# missing PerformanceIndicatorType
$docp=~s|<PerformanceIndicator ValueChainStage="([^"]*?)"\s*>|<PerformanceIndicator ValueChainStage="\1" PerformanceIndicatorType="">|g;
# missing ValueChainStage
$docp=~s|<PerformanceIndicator PerformanceIndicatorType="([^"]*?)"\s*>|<PerformanceIndicator ValueChainStage="" PerformanceIndicatorType="\1">|g;
# both attributes are missing
$docp=~s|<PerformanceIndicator>|<PerformanceIndicator ValueChainStage="" PerformanceIndicatorType="">|g;



$ug->create();
$uuid1= lc($ug->create_str());


$docp=~s|>PLACEHOLDER_\d+<|>_$uuid1<|g;

$docp=~s|<Relationship>(\s*)<Identifier></Identifier>|<Relationship RelationshipType="">\1<Identifier>_$uuid1</Identifier>|g;
$docp=~s|<Relationship>|<Relationship RelationshipType="">|g;
$docp=~s|<Relationship RelationshipType="">(\s*)<Identifier></Identifier>|<Relationship RelationshipType="">\1<Identifier>_$uuid1</Identifier>|g;

$docp=~s|<Relationship>(\s*)<Identifier/>|<Relationship RelationshipType="">\1<Identifier>_$uuid1</Identifier>|g;

$docp=~s|<Relationship RelationshipType="">(\s*)<Identifier/>|<Relationship>\1<Identifier>_$uuid1</Identifier>|g;

$docp=~s|<Stakeholder>|<Stakeholder StakeholderTypeType="">|g;

# $docp=~s|[\x93\x94]|"|g;


# $docp=~s|<StrategicPlan[^>]*?>|<StrategicPlan xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:stratml="urn:ISO:std:iso:17469:tech:xsd:stratml_core">|;

# 2015/09/29
$docp=~s|-\n\s*|-|g;
$docp=~s|\s*\n\s*| |g;

$docp=~s|<Identifier>([0-9a-f])|<Identifier>_\1|g;
$docp=~s|<Identifier>-|<Identifier>_|g;


if ($instanceurl)
	{
	$docp=~s|<StrategicPlan([^>]*?)>|<StrategicPlan\1><id>$instanceurl</id>|;
	
$docp=~s|<id/>||;
	}





$docp=~s|</StrategicPlan>|</PerformancePlanOrReport>|;

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
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=StratML/out.xml\"/>\n";

print "<body><p><a href=\"StratML/out.xml\">Link</a></p></body>\n";

exit;



#######################################
# GetFileFromURL
#######################################
sub GetFileFromURL {
my $website=$_[0];
my $errorstr=$_[1];
if (!($req = $http->request($website))) 
	{
	print "<html><title>".$website." not available</title>\n";
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