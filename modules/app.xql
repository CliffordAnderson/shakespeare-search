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
 : Alternative to collection would be to use : xmldb:get-child-resources($config:app-root || "/data/indexed-plays")
:)
declare %templates:wrap function app:browse-list-items($node as node(), $model as map(*)){
    for $play in collection($config:app-root || "/data/indexed-plays")
    let $title := $play//tei:titleStmt/tei:title/text()
    let $sort-title := replace(replace($title,'^The ',''),'^A ','')
    let $date := $play//tei:witness[@xml:id = 'shakespeare-online'][1]/tei:date[1]/text()
    let $death := count($play//tei:death)
    let $play-uri := base-uri($play)
    let $uri := replace($play-uri,'/indexed-plays','/plays')
    order by 
        if($app:sort = 'death') then $death
        else if($app:sort = 'date') then $date
        else $title        
        (: Dynamic sort and sort order, does not work, may be eXist bug. Can also use util:eval on whole FLWOR
            if ($app:sort = 'death') then $death else () descending,
            if ($app:sort = 'title') then $sort-title else () ascending,
            if ($app:sort = 'date') then $date else () ascending,
            if (not(exists($app:sort))) then $sort-title else () ascending
        :)
    return 
        app:display-title($title,$uri,$date,$death)
}; 

declare function app:display-title($title as xs:string?,$uri as xs:anyURI?,$date as xs:string?, $death as xs:integer?) as node()*{
        <li>
            <span class="title">{$title}.</span>
            <span class="text-info">Published: </span> {$date}<br/> 
            <span class="text-info"> Mortality Rate: </span> {$death}<br/>
            <a href="play.html?uri={encode-for-uri($uri)}&amp;view=html">HTML</a> | <a href="modules/view-play.xql?uri={encode-for-uri($uri)}&amp;view=pdf">PDF</a> | <a href="modules/view-play.xql?uri={encode-for-uri($uri)}&amp;view=xml">XML</a>
        </li>
};

