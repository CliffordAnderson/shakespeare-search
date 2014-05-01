<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:edate="http://exslt.org/dates-and-times" xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:estr="http://exslt.org/strings" xmlns:local="http://www.pantor.com/ns/local" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.pnp-software.com/XSLTdoc" version="2.0">
    <!-- 
        XSLT code derived from Foldger Digital Texts editions.xsl for use 
        in Vanderbilt's Summer XQuery Institute.
        XSLT is for demonstration puropses only and does not 
        make any claims on complete and accurate HTML/PDF output.
        @Author Winona Salesky wsalesky@gmail.com
    -->
    <xsl:template match="/">
        <div class="row">
            <div class="col-md-12">
                <xsl:apply-templates select="//tei:titleStmt"/>
                <div class="panel-group" id="accordion">
                    <div class="panel-group" id="accordion">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                                        Characters in the Play
                                    </a>
                                </h4>
                            </div>
                            <div id="collapseOne" class="panel-collapse collapse in">
                                <div class="panel-body">
                                    <xsl:apply-templates select="//tei:profileDesc/tei:particDesc" mode="list-char"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <xsl:apply-templates select="//tei:body"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:titleStmt">
        <div class="page-header">
            <h1>
                <xsl:apply-templates select="tei:title"/>
            </h1>
        </div>
        <div class="alert alert-success">
            <p>Folger Shakespeare Library</p>
            <p>
                <a href="http://www.folgerdigitaltexts.org">http://www.folgerdigitaltexts.org</a>
            </p>
        </div>
    </xsl:template>
    <xsl:template match="tei:listPerson" mode="list-char">
        <div style="padding-bottom:.5em;">
            <xsl:choose>
                <xsl:when test="tei:head">
                    <xsl:apply-templates select="tei:head"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="tei:person" mode="list-char"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template mode="list-char" match="tei:person">
        <div style="padding-bottom:.5em;">
            <span class="castName">
                <xsl:apply-templates select="tei:persName" mode="list-char"/>
            </span>,
            <xsl:apply-templates select="tei:state/tei:p/text()"/>
            <xsl:apply-templates select="tei:sex"/>
        </div>
    </xsl:template>
    <xsl:template match="tei:persName | tei:name" mode="list-char">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:person/tei:sex">
        <span>
            <xsl:text> [</xsl:text>
            <xsl:value-of select="."/>]</span>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="tei:pb">
        <a name="p{@n}"/>
        <div class="row" style="background-color:#eee; border-top:1px solid #333; padding:.5em; margin:1em 0;">
            <div class="col-md-1">
                <span class="badge">
                    <xsl:value-of select="@n"/>
                </span>
            </div>
            <div class="col-md-4 small">
                <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
            </div>
            <div class="col-md-7 small">
                (<xsl:value-of select="following-sibling::tei:fw"/>)
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:text/tei:body/tei:pb">
        <a name="p{@n}"/>
    </xsl:template>
    <xsl:template match="tei:div1">
        <a name="line-{@n}.0.0"/>
        <div class="row">
            <div class="col-md-12">
                <xsl:apply-templates/>
            </div>
        </div>
        <hr/>
    </xsl:template>
    <xsl:template match="tei:div1/tei:head">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="tei:div2">
        <a name="line-{../@n}.{@n}.0"/>
        <div class="row" style="margin-bottom:1em;">
            <div class="col-md-12">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:div2/tei:head">
        <h4>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>
    <xsl:template match="tei:head">
        <xsl:choose>
            <xsl:when test="@rend='inline'">
                <span class="italic">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="class" select="translate(@rend,',',' ')"/>
                <div class="centered italic {$class}">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:speaker">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="speaker {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:w|tei:c|tei:pc|tei:w/tei:seg|tei:anchor" xml:space="preserve">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:stage[@type='entrance']">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage centered {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:stage[contains('delivery,location,modifier',@type)]">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:stage[@type='dumbshow']">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:stage[contains(@rend,'inline')]">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:stage[contains(@rend,'centered')]">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage centered {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:stage[@type='mixed']">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:stage[@type='entrance']">
                <span class="stage centered {$class}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend='inline'">
                <span class="stage {$class}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="stage right {$class}">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:stage[@rend='inline']//tei:lb">
        <br/>
        <span class="alignment indentProse">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:stage">
        <xsl:variable name="lineNbr" select="(substring-after(@n,'SD '))"/>
        <a class="hidden" name="line-SD{$lineNbr}">SD</a>
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="stage right {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type][contains('song,verse,letter',@type)]">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span id="{@xml:id}" class="italic {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type='poem']">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span id="{@xml:id}" class="{$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type='letter'][@subtype='closing']">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="closing {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type='letter'][@subtype='signature']">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="right {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type='letter'][@subtype='closing']/tei:seg[@type='letter'][@subtype='signature']">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="closingSig {$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:seg[@type='dramatic']">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:ab[not(@type)][@rend]">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="{$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:hi">
        <xsl:variable name="class" select="translate(@rend,',',' ')"/>
        <span class="{$class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:foreign">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:name">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:title[@rend='italic']">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:title[@rend='quotes']">
        <xsl:text>“</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>”</xsl:text>
    </xsl:template>
    <xsl:template match="tei:gap">
        <xsl:text>…</xsl:text>
    </xsl:template>
    <xsl:template match="tei:w//tei:q">
        <xsl:text>“</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>”</xsl:text>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#quatrain'][@n='2' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAb'][@n='1' or @n='2']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaB'][@n='3']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBb'][@n='2']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAbCCb'][@n='1' or @n='2' or @n='4' or @n='5']">
        <span class="alignment" style="padding-left:25px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAbCCb'][@n='3' or @n='6']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aA'][@n='2']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBcB'][@n='2' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAbC'][@n='1' or @n='2' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAbbA'][@n='1' or @n='2' or @n='5']">
        <span class="alignment" style="padding-left:25px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaBBa'][@n='3' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaBBc'][@n='3' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#abCCb'][@n='3' or @n='4']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaBaaB'][@n='3' or @n='6']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaBccB'][@n='3' or @n='6']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBaBcC'][@n='2' or @n='4' or @n='6']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBBaCC'][@n='2' or @n='3' or @n='5' or @n='6']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBaBccB'][@n='2' or @n='4']">
        <span class="alignment" style="padding-left:30px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aBaBccB'][@n='3' or @n='7']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AAaBBaa'][@n='1' or @n='2' or @n='4' or @n='5']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aabbCCDEED'][@n='5' or @n='6' or @n='8' or @n='9']">
        <span class="alignment" style="padding-left:10px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aabbCCDEED'][@n='7' or @n='10']">
        <span class="alignment" style="padding-left:20px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#AABBbCCDDb'][not(@n='5' or @n='10')]">
        <span class="alignment" style="padding-left:20px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ptr[@type='stanza'][@ana='#aaaBcccB'][@n='4' or @n='8']">
        <span class="alignment" style="padding-left:20px;">&#160;</span>
    </xsl:template>
    <xsl:template match="tei:ab">
        <span class="indentInline">&#160;</span>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Suppress elements -->
    <xsl:template match="tei:del | tei:app | tei:back | tei:fw[@type='header']"/>
</xsl:stylesheet>