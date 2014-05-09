xquery version "3.0";

module namespace search="http://localhost:8080/exist/apps/xq-institute/search";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare variable $search:term {request:get-parameter('term','') cast as xs:string};

(:~
 : Build browse function for shakespeare plays
 : may be better off using only full text queries, not range, as the taging of every word does odd things to range index
 : NOTE need to build paging
 : NOTE add sort options
 : NOTE need to build facets
 : NOTE include kwic 
:)
declare function search:simple(){
    for $plays in collection($config:app-root || "/data") 
    let $hits := $plays//tei:sp[ft:query(., $search:term)]
    for $hit at $p in subsequence($hits, 1, 20)
    let $uri := base-uri($hit)
    let $title := doc($uri)//tei:titleStmt/tei:title/text()
    return 
        <li>{$title} [{$uri}]</li>
};

declare %templates:wrap function search:display-results($node as node(), $model as map(*)){
(<h4>{count(search:simple())} results for: {$search:term}</h4>,
 <ul>
    {search:simple()}
 </ul>)    
};