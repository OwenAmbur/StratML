#!/usr/bin/perl

use Data::UUID;

$ug = new Data::UUID; 


# open(OUT,">../temp/temp.xml");
# print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
#open(OUT,">/forms/temp-stratml/temp.xml");
open(OUT,">temp-stratml/temp.xml");
print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";

# print OUT "<?xml-stylesheet type=\"text/xsl\" href=\"Crane-StratML2HTML.xsl\"?>\n";

#print OUT "<?xml-stylesheet type=\"text/xsl\" href=\"http://stratml.us/forms/part2stratml.xsl\"?>\n";



if ($content_length = $ENV{'CONTENT_LENGTH'}) {
  if (read (STDIN, $posted_information, $content_length)) {
	$posted_information=~s| xmlns="[^"]*?"||g;

$plantype="Strategic_Plan";

# Changed 9/2/2015 for Part 2 version

 if ($posted_information=~m| Type="([^"]*?)"|)

   {$plantype=$1;}





$posted_information=~s|<StrategicPlan[^>]*?>|<PerformancePlanOrReport xmlns="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n\n xsi:schemaLocation="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport http://stratml.us/references/PerformancePlanOrReport20160216.xsd" Type="$plantype">|;
# Changed 2019 Alian
$posted_information=~s|</StrategicPlan>|</PerformancePlanOrReport>|;





# $posted_information=~s|<[^>]*?>|<PerformancePlanOrReport xmlns="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ISO:std:iso:17469:tech:xsd:PerformancePlanOrReport http://stratml.us/references/PerformancePlanOrReport20160216.xsd" Type="$plantype">|;



# $posted_information=~s|<StartDate/>||g;

# $posted_information=~s|<StartDate>\s*</StartDate>||g;

# $posted_information=~s|<EndDate/>||g;

# $posted_information=~s|<EndDate>\s*</EndDate>||g;

# $posted_information=~s|<PublicationDate/>||g;

# $posted_information=~s|<PublicationDate>\s*</PublicationDate>||g;

$posted_information=~s|<Source/>||g;

$posted_information=~s|<Source>\s*</Source>||g;

$posted_information=~s|<Submitter><GivenName/><Surname/><PhoneNumber/><EmailAddress/></Submitter>||;



# Change 9/10/2015

$posted_information=~s|\s*StakeholderTypeType=""||g;

$posted_information=~s|\s*ValueChainStage=""||g;

$posted_information=~s|\s*RelationshipType=""||g;



$posted_information=~s|PerformanceIndicatorType=""||g;

$posted_information=~s|StakeholderTypeType=""||g;

$posted_information=~s|<RoleType/>||g;

$posted_information=~s|<RoleType>\s*</RoleType>||g;

$posted_information=~s|<NumberOfUnits/>||g;

$posted_information=~s|<NumberOfUnits>\s*</NumberOfUnits>||g;



# Changed 6/6/12 

# $posted_information=~s|StrategicPlan>|StrategicPlan xsi:schemaLocation="http://www.stratml.net http://xml.gov/stratml/references/StrategicPlan.xsd" 

# xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.stratml.net">|;

# $posted_information=~s|StrategicPlan>|StrategicPlan xmlns="http://www.stratml.net" xmlns:xsi="http://www.stratml.net http://www.w3.org/2001/XMLSchema-instance"  

# xsi:schemaLocation="http://xml.gov/stratml/references/StrategicPlan.xsd">|;



		$posted_information=~s|<id></id>||;

		$posted_information=~s|<id/>||;



		$posted_information=~s|<id>[^<]*?</id>||;

		

	

		AddIds();







		print OUT $posted_information;

		close(OUT);





$planname="NoPlanName";

if ($posted_information=~m@(<Name>[^<]*?</Name>)@)

    {

    $planname=$1;

    $planname=~s|</?Name>||g;

    $planname=~s|\s+|_|g;    

    $planname=~s|/|_|g;

    $planname=~s|\\|_|g;

    $planname=~s|\x00||g;

    }	





if ($posted_information=~m@<Organization>\s*(<Name>[^<]*?</Name>|<Name/>)\s*(<Acronym>[^<]*?</Acronym>|<Acronym/>)\s*<Identifier>([^<]*?)</Identifier>@)

    {

    $n=$1;

    $acronym=$2;

    $id=$3;

    if ($acronym=~m|<Acronym/>|) {$acronym="BLANK";}

    $acronym=~s|</?Acronym>||g;

    $acronym=~s|/|_|g;

    $acronym=~s|\\|_|g;

    $acronym=~s|\s|_|g;

    $acronym=~s|\x00||g;

   # mkdir("../StratML/XML/".$acronym);

   mkdir("../StratML/XML/".$planname);





  #  open(OUT,">../StratML/XML/".$acronym."/".$id.".xml");

    open(OUT,">../StratML/XML/".$planname."/".$id.".xml");





    print OUT "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";

    print OUT $posted_information;

    close(OUT);



# print "Content-type: text/html\n\n";

# print "<html><body>YES ".$acronym." ".$id."</body>"; 

# exit;

    }
		print "Content-type: text/html\n\n";	
		print "<html><head>";
		print "  <meta http-equiv=\"Refresh\" content=\"0; url=temp-stratml/temp.xml\">\n";
		print "</head><body>";
		print "  <p>Please follow <a href=\"temp-stratml/temp.xml\">link</a>!</p>\n";
		print "</body></html>\n";
		exit;

		}		
	}
print "Content-type: text/html\n\n";	



print "<html><head>";
print     "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n";
print     "<meta http-equiv=\"Content-Style-Type\" content=\"text/plain; charset=us-ascii\"/>\n";
print     "<meta http-equiv=\"Pragma\" content=\"no-cache\">\n";
print     "<meta http-equiv=\"Expires\" content=\"-1\">\n";
print "</head>\n";

print "<body><h1>A problem occurred extracting and creating the XML file</h1></body></html>";


sub AddIds {
$ug->create();
$l=gmtime();

$uuid1= lc($ug->create_str());



# 2015/09/14 - to not uuid relationship/identifiers.  remover if/when identifier changes names
# $posted_information=~s|<Relationship>(\s*)<Identifier>|<Relationship>\1<Identifier8>|g;
# $posted_information=~s|<Relationship RelationshipType="">(\s*)<Identifier>|<Relationship>\1<Identifier8>|g;

# $posted_information=~s|<Relationship>(\s*)<Identifier/>|<Relationship>\1<Identifier8/>|g;
# $posted_information=~s|<Relationship RelationshipType="">(\s*)<Identifier/>|<Relationship>\1<Identifier8/>|g;




# 2012/07/22

# while ($posted_information=~s|<Identifier>[^<]*?</Identifier>|<Identifier1>_$uuid1</Identifier>|)
# while ($posted_information=~s|<Identifier>\s*</Identifier>|<Identifier1>_$uuid1</Identifier>|)
#	{	
#	$uuid1="";
#	
#	$l++;
#	$w="http://www.xmldatasets.net/".$l;
#	# $uuid1 = lc($ug->create_from_name_str("stratml".$l, $w));
#	$uuid1=lc($ug->create_str());
#	}


# 2014/02/18 
$uuid1= lc($ug->create_str());

while ($posted_information=~s|<Identifier/>|<Identifier1>_$uuid1</Identifier>|)
	{	
	$uuid1="";

	$l++;
	$w="http://www.legisworks.org/".$l;
	# $uuid1 = lc($ug->create_from_name_str("stratml".$l, $w));
	$uuid1=lc($ug->create_str());
	}


$posted_information=~s|<Identifier1>|<Identifier>|g;

$highest=0;
while ($posted_information=~s|PLACEHOLDER_(\d+)|PLACEHOLDERX_\1|)
     {
     $p=$1;
     if ($p>$highest) {$highest=$p;}
     }
$posted_information=~s|PLACEHOLDERX_|PLACEHOLDER_|g;



# 2015/09/24 

$uuid1=$highest+1;
while ($posted_information=~s|<Identifier>\[To_be_identified\]</Identifier>|<Identifier>PLACEHOLDER_$uuid1</Identifier>|)
	{	
	$uuid1++;
	}


# $posted_information=~s|<Identifier>\[To_be_identified\]</Identifier>|<Identifier/>|g;

# 2015/09/14 - to not uuid relationship/identifiers.  remover if/when identifier changes names

# $posted_information=~s|<Identifier8>|<Identifier>|g;
# $posted_information=~s|<Identifier8/>|<Identifier/>|g;

}