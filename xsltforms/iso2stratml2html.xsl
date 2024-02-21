<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:i="urn:x-Crane:StratML:Demo"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs i"
                version="1.0">

<xs:doc info="$Id: Crane-StratML2HTML-base.xsl,v 1.6 2008/09/02 15:37:34 gkholman Exp $"
        filename="Crane-StratML2HTML-base.xsl" vocabulary="DocBook" 
        global-ns="i" internal-ns="i" xmlns="">
  <xs:title>Main logic for web presentation</xs:title>
  <para>
    This has web-specific presentation components
  </para>
</xs:doc>

<!-- 
January 2010: This script has been modified to accommodate the updated 
StratML schema.

http://xml.gov/stratml/references/StrategicPlan.xsd 

The primary changes involved changing xpath locations, adding a couple 
of elements (Name, Description, OtherInformation), and changing the linking
ids to use the Identifiers provided within the StratML file.

Redistribution and use in source and binary forms, with or without 
modification, are permitted per the copyright provided below.

Joe Carmel
-->


<!--
Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/res-stratml.htm

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer. 
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution. 
- The name of the author may not be used to endorse or promote products 
  derived from this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR 
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN 
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Note: for your reference, the above is the "Modified BSD license", this text
      was obtained 2002-12-16 at http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5
-->


<xs:template xmlns="">
  <para>Start here</para>
</xs:template>
<xsl:template match="/">
  <!--determine that the document element is acceptable-->
  <xsl:call-template name="i:checkInput"/>
  <!--determine that the calling arguments are acceptable-->
  <xsl:variable name="errors">
    <xsl:if test="not($otherInfo='yes' or $otherInfo='no')">
      <xsl:text>Invalid value for $otherInfo: </xsl:text>
      <xsl:value-of select="$otherInfo"/>
      <xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:if test="string($errors)">
    <xsl:message terminate="yes">
      <xsl:value-of select="$otherInfo"/>
    </xsl:message>
  </xsl:if>
  <!--produce the output-->
  <html>
    <xsl:text>
    </xsl:text>
    <xsl:comment> End result created using Crane-StratML2HTML.xsl </xsl:comment>
    <xsl:text>
    </xsl:text>
    <xsl:comment> See:  http://www.CraneSoftwrights.com/links/res-stratml.htm </xsl:comment>
    <xsl:text>
    </xsl:text>
    <head>
      <title>Strategic Plan - Source: <xsl:value-of select="*/Source"/></title>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <!--these styles are assumed by the stylesheet; can be overridden-->
      <style type="text/css">
/*Global*/
pre,samp {font-family:monospace;font-size:80%}
/*Heading information*/
.doc {font-family:Century; font-size:13pt}
.docheading {font-size:20pt;text-align:center;font-weight:bold}
.docsubheading {font-family:Helvetica;font-size:15pt;text-align:center;color:green}
.inlinedocsubheading {font-family:Helvetica;font-size:15pt;text-align:left;color:green}


.sourceheading {}
.herald {font-family:sans-serif;font-size:12pt;font-weight:bold}
/*TOC*/
.toctitle {text-align:center; font-size:16pt;color:green;font-weight:bold}
.tocentry {margin-left:.5in;text-indent:.25in;
           margin-top:0pt;margin-bottom:0pt}
.tocsubentry {margin-left:1in;text-indent:.25in;
              margin-top:0pt;margin-bottom:0pt}
/*Body*/
.vmvhead {font-size:15pt;font-weight:bold}
.vmvdesc {margin-left:.25in}
.goalsep {display:visible;margin-top:16pt;margin-bottom:0pt}
.goalhead {text-align:center;font-size:16pt;color:green;font-weight:bold;
           margin-top:8pt}
.goaldesc {text-align:center;margin-left:25%;margin-right:25%}
.goalstakeholder {text-align:center;margin-left:10%;margin-right:10%}
.objhead {font-size:15pt}
.objstakeholder {margin-left:.25in}
.para {margin-left:.25in;margin-right:.25in;text-indent:.25in}
/*Meta*/
.meta {font-size:8pt;text-align:right;margin-top:0pt;margin-bottom:0pt}
      </style>
      <xsl:text>
      </xsl:text>
      <xsl:comment>End-user styles override built-in styles.</xsl:comment>
      <xsl:text>
      </xsl:text>
      <link type="text/css" rel="stylesheet" href="Crane-StratML2HTML.css"/>
    </head>
    <body class="doc">
      <!--present all of the title information-->
      <hr width="3px"/>
      <p class="docheading">
        Strategic Plan       </p>
  
  <p class="docsubheading"><xsl:value-of select="/StrategicPlan/Name"/></p>
  <p class="para"><xsl:value-of select="/StrategicPlan/Description"/></p>
  
  
  <p class="para"><xsl:value-of select="/StrategicPlan/OtherInformation"/></p>
  	      
        
      <p class="docsubheading">
        Source: 
        <a href="{//AdministrativeInformation/Source}" target="_blank">
          <samp class="sourceheading"><xsl:value-of select="//AdministrativeInformation/Source"/></samp>
        </a>
      </p>
      <p class="docsubheading">
        <xsl:if test="//AdministrativeInformation/StartDate != ''">Start: <xsl:value-of select="//AdministrativeInformation/StartDate"/></xsl:if>
        <xsl:if test="//AdministrativeInformation/EndDate !=''">End: <xsl:value-of select="//AdministrativeInformation/EndDate"/></xsl:if>
        <xsl:if test="//AdministrativeInformation/PublicationDate != ''">Publication Date: <xsl:value-of select="//AdministrativeInformation/PublicationDate"/></xsl:if>
       </p>
            <p class="docsubheading">Submitter: <xsl:apply-templates select="//Submitter"/></p>
      <table summary="submitter and organization information" class="doc">
        <tr valign="top" width="80%">
          <td>
            <p class="inlinedocsubheading">Organization:</p>
            <xsl:apply-templates select="//Organization"/>
          </td>
        </tr>
      </table>
      <!--table of contents-->
      <xsl:call-template name="i:toc"/>
      <!--body-->
      <xsl:apply-templates select="//Vision|//Mission"/>
      <xsl:if test="*/Value">
        <p class="vmvhead" id="values_">
          Value<xsl:if test="count(*/Value)>1">s</xsl:if>
        </p>
        <xsl:for-each select="//Value">
          <p class="vmvdesc" id="{generate-id()}">
            <xsl:apply-templates select="Name"/>
            <xsl:for-each select="Description">
              <xsl:text>: </xsl:text>
              <xsl:apply-templates select="."/>
            </xsl:for-each>
          </p>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates select="//Goal"/>
      <!--meta data-->

      <p class="meta">
        <a href="http://www.CraneSoftwrights.com/links/res-stratml.htm"
           target="_blank">
          Crane Softwrights Ltd.
        </a>
      </p>
      <p class="meta">
        Stylesheet revision (main): 2010/01/12 15:37:34 $(UTC)
        <br/>
        Stylesheet revision (base): 2010/01/27 15:37:34 $(UTC)
      </p>
      <p class="meta">
        <a href="http://www.xmldatasets.net/StratML"
           target="_blank">XMLDatasets.net</a><br/>
        Stylesheet revision (Part 1 - ISO): 2015/05/02 $(UTC)
        <br/>

      </p>
      
    </body>
  </html>
</xsl:template>

<xs:template xmlns="">
  <para>Present the submitter block of information</para>
</xs:template>
<xsl:template match="Submitter">
    <a href="mailto:{EmailAddress[normalize-space(.)]}">
<xsl:value-of select="GivenName[normalize-space(.)]"/><xsl:text> </xsl:text>
    <xsl:value-of select="Surname[normalize-space(.)]"/></a>

<xsl:if test="PhoneNumber !=''"> (
    <xsl:for-each select="PhoneNumber[normalize-space(.)]">

        <xsl:value-of select="."/>) <xsl:text> </xsl:text>        
    </xsl:for-each>
</xsl:if>
    
</xsl:template>

<xs:template xmlns="">
  <para>Present the organization block of information</para>
</xs:template>
<xsl:template match="Organization">
  <blockquote>
    <xsl:for-each select="Name">
      <p>
        <b class="herald">Name: </b>
        <xsl:value-of select="."/>
      </p>
    </xsl:for-each>
    <xsl:for-each select="Acronym">
      <p>
        <b class="herald">Acronym: </b>
        <xsl:value-of select="."/>
      </p>
    </xsl:for-each>      
     <xsl:if test="Stakeholder/Name">
     <p><b class="herald">Stakeholders</b></p>
    <xsl:for-each select="Stakeholder">
    <p>
        <xsl:if test="@StakeholderTypeType!=''">(<xsl:value-of select="@StakeholderTypeType"/>) </xsl:if>
        <b><xsl:value-of select="Name"/></b>: <xsl:value-of select="Description"/>
      </p>
    </xsl:for-each>
    </xsl:if>
    
  </blockquote>
</xsl:template>

<xs:template xmlns="">
  <para>Create a hyperlinked table of contents</para>
</xs:template>
<xsl:template name="i:toc">
  <xsl:for-each select="*">
    <p class="toctitle">Table of contents<br/><hr width="60%"/></p>
    <xsl:for-each select="Vision">
      <p class="tocentry">
        <a href="#{Identifier}">Vision</a>
      </p>
    </xsl:for-each>
    <xsl:for-each select="Mission">
      <p class="tocentry">
        <a href="#{Identifier}">Mission</a>
      </p>
    </xsl:for-each>
    <xsl:if test="Value">
      <p class="tocentry">
        <a href="#values_">
          Value<xsl:if test="count(Value)>1">s</xsl:if>
        </a>
      </p>
      <xsl:for-each select="Value">
        <p class="tocsubentry">
          <a href="#{generate-id(.)}">
            <xsl:apply-templates select="Name"/>
          </a>
        </p>
      </xsl:for-each>
    </xsl:if>
    <xsl:for-each select="StrategicPlanCore/Goal">
      <p class="tocentry">
<!--      <xsl:element name="a"><xsl:attribute name="href="><xsl:value-of select="Identifier"/> 

      </xsl:attribute> -->
        <a href="#{Identifier}">Goal          <xsl:for-each select="SequenceIndicator">
            <xsl:apply-templates select="."/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
          <xsl:apply-templates select="Name"/>
		</a>
      </p>
      <xsl:for-each select="Objective">
        <p class="tocsubentry">
          <a href="#{Identifer}">
            <xsl:for-each select="SequenceIndicator">
              <xsl:apply-templates select="."/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:apply-templates select="Name"/>
          </a>
        </p>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xs:template xmlns="">
  <para>Present each goal</para>
</xs:template>
<xsl:template match="Goal">
  <hr class="goalsep"/>
  <p class="goalhead" id="{Identifier}">
  	<a href="#{Identifier}">
    <xsl:text>Goal</xsl:text>
    
    <xsl:for-each select="SequenceIndicator">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    </a>
    
    <xsl:for-each select="Name">
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    

    
  </p>
  <xsl:for-each select="Description">
    <p class="goaldesc">
      <xsl:apply-templates/>
    </p>
  </xsl:for-each>
  <xsl:for-each select="Stakeholder[normalize-space(.)]">
    <p class="goalstakeholder">
      <xsl:text>(</xsl:text>
      <xsl:for-each select="Name">
        <xsl:apply-templates select="."/>
        <xsl:text>: </xsl:text>
      </xsl:for-each>
      <xsl:apply-templates select="Description"/>
      <xsl:text>)</xsl:text>
    </p>
  </xsl:for-each>
  <xsl:for-each select="Objective">
    <p class="tocsubentry">
      <a href="#{Identifier}">
        <xsl:for-each select="SequenceIndicator">
          <xsl:apply-templates select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:apply-templates select="Name"/><br/>
      </a>
    </p>
  </xsl:for-each>

  <xsl:if test="OtherInformation!=''">
  
  <xsl:for-each select="OtherInformation[$otherInfo='yes']">
    <p class="tocsubentry">
      <a href="#{generate-id(.)}">
        Other Information
      </a>
    </p>
    
  </xsl:for-each>
  <xsl:apply-templates select="Objective|OtherInformation[$otherInfo='yes']"/>
  </xsl:if>
</xsl:template>

<xs:template xmlns="">
  <para>Present the vision and mission</para>
</xs:template>
<xsl:template match="Vision|Mission">
  <p class="vmvhead" id="{Identifier}">
  <a href="#{Identifier}">
    <xsl:choose>
      <xsl:when test="self::Vision">Vision</xsl:when>
      <xsl:otherwise>Mission</xsl:otherwise>
    </xsl:choose></a>
  </p>
  <p class="vmvdesc">
    <xsl:apply-templates select="Description"/>
  </p>
</xsl:template>



<xsl:template match="strong">
  <b>
    <xsl:apply-templates select="."/>
  </b>
</xsl:template>




<xs:template xmlns="">
  <para>Presenting an objective</para>
</xs:template>
<xsl:template match="Objective">
  <p class="objhead" id="{./Identifier}">
 
      <a href="#{./Identifier}">
    <xsl:text>Objective</xsl:text>
    <xsl:for-each select="SequenceIndicator">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="."/>
      </xsl:for-each>
      </a>
      
    <xsl:for-each select="Name">
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </p>
  <xsl:for-each select="Stakeholder[*]">
    <p class="objstakeholder">
      <xsl:text>(</xsl:text>
      <xsl:for-each select="Name">
        <xsl:apply-templates select="."/>
        <xsl:text>: </xsl:text>
      </xsl:for-each>
      <xsl:apply-templates select="Description"/>
      <xsl:text>)</xsl:text>
    </p>
  </xsl:for-each>
  <xsl:for-each select="Description">
    <p class="para">
      <xsl:apply-templates select="."/>
    </p>
  </xsl:for-each>
  <xsl:apply-templates select="OtherInformation[$otherInfo='yes']"/>
</xsl:template>

<xs:template xmlns="">
  <para>Presenting any other information</para>
</xs:template>
<xsl:template match="OtherInformation">
<xsl:if test=". !=''">  <p class="objhead" id="{generate-id(.)}">
    <xsl:text>Other information:</xsl:text>
  </p>
  <p class="para">
    <xsl:apply-templates/>
  </p>
 </xsl:if>
</xsl:template>

</xsl:stylesheet>