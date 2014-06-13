xquery version "3.0";

module namespace play="http://xqueryinstitute.org/play";

(:
 : Retrieve play xml transform with xsl for html output
 : For local installations you can not use the html APIs, must use the text API
 : text API seems to have a character limitation. 
:)

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
import module namespace alchemy="http://xqueryinstitute.org/alchemy" at "alchemy.xqm" ;

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
    let $rec := xmldb:document($uri)/tei:TEI
    return 
        <div>
            <div class="col-md-8">
                {play:view-play-html($rec)}
            </div>,
            <div class="col-md-4">
                <div id="alchemy" style="padding-top:6em;">
                    <h4>Text analysis by AlchemyAPI:</h4>
                    {alchemy:get-tone($rec)}
                </div>
            </div>
        </div>
};

