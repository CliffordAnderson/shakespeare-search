<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xqi="http://xqueryinstitute.org/ns" 
    xmlns:edate="http://exslt.org/dates-and-times" xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:estr="http://exslt.org/strings" xmlns:local="http://www.pantor.com/ns/local" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.pnp-software.com/XSLTdoc" version="2.0">
    <!-- 
        XSLT code derived from Foldger Digital Texts editions.xsl for use 
        in Vanderbilt's Summer XQuery Institute.
        XSLT is for demonstration puropses only and does not 
        make any claims on complete and accurate HTML/PDF output.
        @Author Winona Salesky wsalesky@gmail.com
    -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:revisionDesc">
        <revisionDesc xmlns:tei="http://www.tei-c.org/ns/1.0">
            <change who="http://xqueryinstitute.org/wsalesky" when="{current-date()}">
                Transformed data for easier indexing For: XQueryInstitute
            </change>
        </revisionDesc>
    </xsl:template>
    <xsl:template match="*">
        <xsl:choose>
            <xsl:when test="child::tei:w">
                <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="string-join(tei:w,' ')"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xqi:genre | xqi:performed | tei:front | tei:back | tei:encodingDesc | tei:w | tei:c | tei:lb | tei:pc | tei:fw "/>
</xsl:stylesheet>