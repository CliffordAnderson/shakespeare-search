xquery version "3.0";
(: module namespace :)
module namespace facets="http://localhost:8080/exist/apps/xq-institute/facets";

(: Templating modules 
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
:)

(: Namespaces used by query :)
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";

declare function facets:term-callback($term as xs:string, $data as xs:int+) as element() {
let $url-params := request:get-query-string()
let $new-params := replace(request:get-query-string(), '&amp;start=\d+', '')
let $label := 'title'
return
<div freq="{$data[1]}" docs="{$data[2]}" n="{$data[3]}">
    <a href="{concat('?', $url-params,'&amp;fq=',$label,':',$term)}">{$term} [{$data[1]}]</a>
 </div>
};

declare function facets:facets($query-string as xs:string*){
let $coll := collection('/db/apps/xq-institute/data')
let $callback := util:function(xs:QName("facets:term-callback"), 2)
(: declare facets as XPath expressions, relative to the search hits :) 
let $facets := 
  <facets>
    <facet label="play">$coll//tei:titleStmt/tei:title[{$query-string}]</facet>
    <facet label="speaker">$coll//tei:speaker[{$query-string}]</facet>
    <facet label="genre">$coll//xqi:genre[{$query-string}]</facet>
    <facet label="performed">$coll//xqi:performed[{$query-string}]</facet>
    <facet label="date">$coll//tei:witness[tei:date[{$query-string}]]</facet>
  </facets> 
return 
    (: loop over facet XPaths, and evaluate them :) 
    for $facet in $facets//facet
    let $vals := util:eval($facet) 
    let $facet-name := string($facet/@label) 
    return
    (<h4>{$facet-name}</h4>,
      <div>
        {
            let $keys := util:index-keys($vals, '', $callback, 5)
            for $key in $keys
            order by xs:integer($key/@freq) descending
            return $key
        }
      </div>
    )
};