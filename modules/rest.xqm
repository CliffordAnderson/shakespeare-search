xquery version "3.0";

module namespace demo = "http://xqueryinstitute.org/demo";

import module namespace req="http://exquery.org/ns/request";

(: For output annotations; supports html, text, xml, xhtml, html5 :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: For REST annotations :)
declare namespace rest = "http://exquery.org/ns/restxq";

(: For interacting with the TEI document :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: For outputting Atom feeds :)
declare namespace atom = "http://www.w3.org/2005/Atom";

declare namespace transform = "http://exist-db.org/xquery/transform";


declare
    %rest:GET
    %rest:path("/shakespeare/plays")
    %output:media-type("text/html")
    %output:method("html5")
function demo:get-plays-html() {
    demo:htmlify(demo:list-plays())
};


declare
    %rest:GET
    %rest:path("/shakespeare/plays/json")
    %output:media-type("application/json")
    %output:method("json")
function demo:get-plays-json() {
    demo:list-plays()
};

 declare
     %rest:GET
     %rest:path("/shakespeare/plays/atom")
     %output:media-type("application/atom+xml")
     %output:method("xml")
 function demo:get-plays-atom() {
     demo:atomify(demo:list-plays())
 };

 declare
     %rest:GET
     %rest:path("/shakespeare/play/{$id}")
     %output:media-type("text/html")
     %output:method("html5")
 function demo:get-play($id as xs:string) {
     let $root := doc('/db/apps/xq-institute/data/plays/{$id}.xml')/*
     return transform:transform(
         $root, doc('../resources/xsl/teiHTML.xsl'), ()
     )
 };


declare
    %private
function demo:htmlify($plays as element(plays)) as element(html) {
    <html>
        <head>
            <title>Simple List of Plays</title>
        </head>
        <body>
            <p style="padding: 15px;">
                <table width="33%">
                    <tr>
                        <th style="text-align:left">Title</th>
                        <th style="text-align:left">Author</th>
                    </tr>
                    {
                    for $play in $plays/play
                    return 
                        <tr>
                            <td>{$play/title/text()}</td>
                            <td>{$play/author/text()}</td>
                        </tr>
                    }
                </table>
            </p>
        </body>
    </html>
};

declare
    %private
function demo:atomify($plays as element(plays)) as element(feed) {
    <atom:feed xmlns:atom="http://www.w3.org/2005/Atom">
        <atom:id>http://localhost:8080/exist/restxq/shakespeare/plays/atom</atom:id>
        <atom:title>Example Atom Feed</atom:title>
        <atom:link rel="self" href="http://localhost:8080/exist/restxq/shakespeare/plays/atom"/>
        <atom:updated>{current-dateTime()}</atom:updated>
        {
            (: Update dates aren't in the right format, but we'll pretend they are :)
            for $play in $plays/play
            let $id := $play/id/text()
            return
                <atom:entry>
                    <atom:title>{$play/title/text()}</atom:title>
                    <atom:author>
                        <atom:name>{$play/author/text()}</atom:name>
                    </atom:author>
                    <atom:link href="http://localhost:8080/exist/restxq/shakespeare/play/{$id}"/>
                    <atom:id>http://localhost:8080/exist/restxq/shakespeare/play/{$id}</atom:id>
                    <atom:updated>{$play/updateDate/text()}</atom:updated>
                </atom:entry>
        }
    </atom:feed>
};

declare
    %private
function demo:list-plays() as element(plays) {
    <plays>{
        for $play in collection('/db/apps/xq-institute/data/plays')
        return 
            <play>
                <id>{$play//tei:publicationStmt/tei:idno/text()}</id>
                <title>{$play//tei:titleStmt/tei:title/text()}</title>
                <author>{$play//tei:titleStmt/tei:author/text()}</author>
                <updateDate>{$play//tei:publicationStmt/tei:date/text()}</updateDate>
            </play>
    }</plays>
};


