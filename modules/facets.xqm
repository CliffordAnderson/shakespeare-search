xquery version "3.0";
(: module namespace :)
module namespace facets="http://xqueryinstitute.org/facets";

(: Namespaces used by query :)
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";

(:~
 : Callback function used by index-keys() function, formats index-keys results
:)
declare function facets:term-callback($term as xs:string, $data as xs:int+) as element() {
    <span freq="{$data[1]}" docs="{$data[2]}" n="{$data[3]}">{$term}</span> 
};

(:~
 : Build facets based on search results
:)
declare function facets:facets($hits as node()*) as node()*{
let $callback := util:function(xs:QName("facets:term-callback"), 2)
(: declare facets as XPath expressions, relative to the search hits :) 
let $facets := 
  <facets>
    <facet label="play">$hits/ancestor::*//tei:titleStmt/tei:title</facet>
    <facet label="speaker">$hits//tei:speaker</facet>
    <facet label="genre">$hits/ancestor::tei:TEI//xqi:genre</facet>
    <facet label="performed">$hits/ancestor::*//xqi:performed</facet>
    <facet label="date">$hits/ancestor::*//tei:witness/tei:date</facet>
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
            let $keys := util:index-keys($vals, '', $callback, 100)
            let $sorted-keys := 
                for $key in $keys
                order by xs:integer($key/@freq) descending
                return $key
            for $sorted-key in subsequence($sorted-keys,1,5)
            let $url-params := request:get-query-string()
            let $new-params := replace(request:get-query-string(), '&amp;start=\d+', '')
            let $term := $sorted-key/text()
            return 
            <div>
                <a href="{concat('?', $url-params,'&amp;',$facet-name,'=',$term)}">{$sorted-key} {concat(' [',$sorted-key/@freq,']')}</a>
            </div>
        }
      </div>
    )
};