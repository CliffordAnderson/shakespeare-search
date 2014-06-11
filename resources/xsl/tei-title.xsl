<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="1.0">
    <xsl:template match="/">
        <div>
            <h2>
                <xsl:value-of select="//tei:titleStmt/tei:title"/>
            </h2>
            <div class="author">
                <span style="font-weight: bold;">Author:</span>
                <xsl:value-of select="//tei:titleStmt/tei:author"/>
            </div>
            <div class="editor">
                <xsl:choose>
                    <xsl:when test="count(//tei:titleStmt/tei:editor) &gt; 1">
                        <span style="font-weight: bold;">Editors:</span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span style="font-weight: bold;">Editor:</span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="//tei:titleStmt/tei:editor" separator=", "/>
            </div>
            <div class="note">
                <span style="font-weight: bold;">
                    <xsl:value-of select="//tei:respStmt/tei:resp"/>
                </span>
                <xsl:value-of select="//tei:respStmt/tei:persName" separator=", "/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>