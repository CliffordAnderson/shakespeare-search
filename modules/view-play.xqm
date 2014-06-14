xquery version "3.0";

module namespace play="http://xqueryinstitute.org/play";

(:
 : Retrieve play xml transform with xsl for html output
:)

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";

(:~
 : Runs play through xslt transformation
 : @param $uri passes internal uri for play
:)
declare function play:view-play-html($rec as node()){
    transform:transform($rec, doc('../resources/xsl/teiHTML.xsl'),() )
};

(:~
 : Retrieve play xml transform with xsl for html output
 : @param $uri passes internal uri for play
:)
declare %templates:wrap function play:get-play($node as node(), $model as map(*)) as node(){
    let $uri := request:get-parameter('uri', '')
    let $displayURI := replace($uri,'/indexed-plays','/plays')
    let $rec := doc($displayURI)/tei:TEI
    return 
        <div>
            <div class="col-md-12">
                {play:view-play-html($rec)}
            </div>
        </div>
};

