xquery version "3.0";

module namespace demo = "http://xqueryinstitute.org/demo";

import module namespace req="http://exquery.org/ns/request";

(: For output annotations :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: For REST annotations :)
declare namespace rest = "http://exquery.org/ns/restxq";

(: For interacting with the TEI document :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: For outputting Atom feeds :)
declare namespace atom = "http://www.w3.org/2005/Atom";

declare namespace transform = "http://exist-db.org/xquery/transform";

declare namespace xmldb = "http://exist-db.org/xquery/xmldb";


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
    %rest:DELETE
    %rest:path("/shakespeare/plays/delete/{$id}")
    %output:media-type("text/txt")
    %output:method("text")
function demo:delete-play($id as xs:string) {
    if (exists(doc('/db/apps/xq-institute/data/plays/' || $id || '.xml')))
    then (
        xmldb:remove('/db/apps/xq-institute/data/plays', $id || '.xml'),
        if (exists(doc('/db/apps/xq-institute/data/plays/' || $id || '.xml')))
        then demo:respond(500, 'Item was not successfully deleted')
        else demo:respond(200, 'Item was successfully deleted')
    )
    else demo:respond(404, 'Item to be deleted did not exist!')
};

declare
    %rest:PUT("{$data}")
    %rest:path("/shakespeare/plays/add/{$id}")
    %output:media-type("text/txt")
    %output:method("text")
function demo:put-play($id as xs:string, $data as node()) {
    if (not(exists(doc('/db/apps/xq-institute/data/plays/' || $id || '.xml'))))
    then (
        let $item := xmldb:store('/db/apps/xq-institute/data/plays', $id || '.xml', $data)
        return (),
        if (exists(doc('/db/apps/xq-institute/data/plays/' || $id || '.xml')))
        then demo:respond(201, 'Item successfully created on the server')
        else demo:respond(500, 'Item failed to be created on the server')
    )
    else demo:respond(409, 'Item already exists! Use POST to update it.')
};

declare
    %rest:POST('{$data}')
    %rest:path('/shakespeare/plays/update/{$id}')
    %output:media-type('text/txt')
    %output:method("text")
function demo:post-play($id as xs:string, $data as item()) {
    if (exists(doc('/db/apps/xq-institute/data/plays/' || $id || '.xml')))
    then
      update insert
        <tei:change
          who='http://xqueryinstitute.org/{$data}'
          when='{current-dateTime()}'
        >Change made via POST.</tei:change>
      into
        doc('/db/apps/xq-institute/data/plays/'
        || $id || '.xml')//tei:revisionDesc
    else demo:respond(404, 'Unable to find item to update.')
};

declare
    %rest:GET
    %rest:path("/shakespeare/play/{$id}")
    %output:media-type("text/html")
    %output:method("html5")
function demo:get-play($id as xs:string) {
    let $root := doc('../data/plays/' || $id || '.xml')
    return
        <html>
            <head>
                <title>{
                    $root//tei:titleStmt/tei:title/text()
                }</title>
            </head>
            <body>{
                transform:transform($root,
                doc('../resources/xsl/teiHTML.xsl'), ())
            }</body>
        </html>
};

declare
    %rest:GET
    %rest:path("/shakespeare/play")
    %rest:query-param("id", "{$id}", "H8")
    %output:media-type("text/html")
    %output:method("html5")
function demo:get-play-by($id as xs:string*) {
    let $root := doc('../data/plays/' || $id || '.xml')
    return
        <html>
            <head>
                <title>{
                    $root//tei:titleStmt/tei:title/text()
                }</title>
            </head>
            <body>{
                transform:transform($root,
                doc('../resources/xsl/teiHTML.xsl'), ())
            }</body>
        </html>
};

(: 
 : Note: This is different from the response
 : format of the HTTP Response XQuery library.
 :)
declare
    %private
function demo:respond($code as xs:int, $message as xs:string) {
    (
        <rest:response>
            <http:response status="{$code}"/>
        </rest:response>, 
        $message
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
    let $server := 'http://localhost:8080/exist/restxq/shakespeare'
    return
        <atom:feed xmlns:atom="http://www.w3.org/2005/Atom">
            <atom:id>{$server}/plays/atom</atom:id>
            <atom:title>Example Atom Feed</atom:title>
            <atom:link rel="self" href="{$server}/plays/atom"/>
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
                        <atom:link href="{$server}/play/{$id}"/>
                        <atom:id>{$server}/play/{$id}</atom:id>
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


