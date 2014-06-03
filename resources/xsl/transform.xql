xquery version "3.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";

declare function local:xslt($doc as node()){
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:edate="http://exslt.org/dates-and-times" xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:estr="http://exslt.org/strings" xmlns:local="http://www.pantor.com/ns/local" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.pnp-software.com/XSLTdoc" version="2.0">
 <xsl:template match="/">
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="tei:teiHeader"/>
                <xsl:apply-templates select="tei:body"/>
            </TEI>
        </xsl:template>
        <xsl:template match="tei:revisionDesc">
            <revisionDesc>
                <change who="http://xqueryinstitute.org/wsalesky" when="{current-date()}">
                    Transformed data for easier indexing For: XQueryInstitute
                </change> 
            </revisionDesc> 
        </xsl:template>
        <xsl:template match="tei:teiHeader">
            <fileDesc>
                <xsl:copy-of select="tei:titleStmt"/>
            </fileDesc>
            <xsl:apply-templates select="tei:revisionDesc"/>
        </xsl:template>
        <xsl:template match="div1">
            <div1>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </div1>
        </xsl:template>

    <xsl:template match="tei:stage | tei:head | tei:speaker | tei:sp">
        <xsl:element name="{local-name(.)}">
        <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:value-of select="string-join(tei:w,' ')"/>    
        </xsl:element>
    </xsl:template>
 
        <xsl:template match="tei:front | tei:back | 
            tei:encodingDesc | tei:w | tei:c | tei:lb 
            | tei:pc | tei:fw "/>
    </xsl:stylesheet> 
};
(:~
 : Add fulltext fields for faster indexing. 
 : Uses locally defined namespace to differentiate between local and tei elements
 : If using in production would have to add a trigger to rerun when documents are updated.
:)
for $doc-index in collection('/db/apps/xq-institute/data')[1]
let $uri := base-uri($doc-index)
let $doc := xmldb:document($uri) 
return transform:transform($rec, local:xslt($doc),() )
  