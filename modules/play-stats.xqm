xquery version "3.0";

module namespace stats="http://xqueryinstitute.org/stats";

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
declare function stats:view-play-stats($rec as node()){
let $speakers := count(distinct-values($rec//tei:sp/tei:speaker))
let $words := count($rec/tei:sp//tei:w)
return 
   <div>
    <div>Speakers: {$speakers}</div>
   </div>
};

(:~
 : Retrieve play xml transform with xsl for html output
 : @param $uri passes internal uri for play
:)
declare %templates:wrap function stats:get-play-stats($node as node(), $model as map(*)) as node(){
    let $uri := request:get-parameter('uri', '')
    let $displayURI := replace($uri,'/plays','/indexed-plays')
    let $rec := doc($uri)/tei:TEI
    return
        <div>
            <h1>{$rec//tei:titleStmt/tei:title/text()}</h1>
            <p class="alert alert-success">
                <a href="play.html?uri={$uri}">Full text</a>
            </p>
            <div>
              {(:stats:view-play-stats($rec):) ''}
              {alchemy:get-tone($rec)}
            </div>            
        </div>
              
       
};

