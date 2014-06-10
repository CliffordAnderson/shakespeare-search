<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xqi="http://xqueryinstitute.org/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="/tei:TEI/child::*"/>
        </TEI>
    </xsl:template>
    <xsl:template match="tei:revisionDesc">
        <revisionDesc>
            <change who="http://xqueryinstitute.org/wsalesky" when="{current-date()}">
                Transformed data for easier indexing For: XQueryInstitute
            </change>
        </revisionDesc>
    </xsl:template>
    <xsl:template match="xqi:genre">
        <genre xmlns="http://xqueryinstitute.org/ns">
            <xsl:value-of select="."/>
        </genre>
    </xsl:template>
    <xsl:template match="xqi:performed">
        <performed xmlns="http://xqueryinstitute.org/ns">
            <xsl:value-of select="."/>
        </performed>
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
    <!-- Suppressed elements -->
    <xsl:template match="tei:front | tei:back | tei:encodingDesc | tei:w | tei:c | tei:lb | tei:pc | tei:fw | tei:milestone "/>
</xsl:stylesheet>