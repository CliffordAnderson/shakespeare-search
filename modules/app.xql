xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/xq-institute/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $app:sort {request:get-parameter('sort', '')};
(:~
 : Browse using sort
 : Using user defined functions to modularize code
:)
declare %templates:wrap function app:browse-list-items($node as node(), $model as map(*)){
    for $play in collection($config:app-root || "/data/indexed-plays")
    let $title := $play//tei:titleStmt/tei:title/text()
    (: NOTE: construct a more robust function to run through a list of stop words using tokenize?:)
    let $sort-title := replace(replace($title,'^The ',''),'^A ','')
    let $date := $play//tei:witness[@xml:id = 'shakespeare-online'][1]/tei:date[1]/text()
    let $uri := base-uri($play)
    order by 
        if($app:sort = 'date') then $date
        else $sort-title
    return 
        app:display-title($title,$uri,$date)
}; 

declare function app:display-title($title as xs:string?,$uri as xs:anyURI?,$date as xs:string?){
        <li>
            {$title}. [Published: {$date}] <br/>
            <a href="play.html?uri={encode-for-uri($uri)}&amp;view=html">HTML</a> | <a href="modules/view-play.xql?uri={encode-for-uri($uri)}&amp;view=pdf">PDF</a> | <a href="modules/view-play.xql?uri={encode-for-uri($uri)}&amp;view=xml">XML</a>
        </li>
};

(:~
 : Retrieve play xml transform with xsl for html output
 : @param $uri passes internal uri for play
 : @param $view view used for output
 :
:)
declare %templates:wrap function app:view-play-html($node as node(), $model as map(*)){
    let $uri := request:get-parameter('uri', '')
    let $displayURI := replace($uri,'/indexed-plays','/plays')
    let $rec := xmldb:document($uri)
    return transform:transform($rec, doc('../resources/xsl/teiHTML.xsl'),() )
};