xquery version "3.0";
(: module namespace :)
module namespace search="http://localhost:8080/exist/apps/xq-institute/search";

(: Templating modules :)
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
import module namespace facets="http://localhost:8080/exist/apps/xq-institute/facets" at "facets.xqm";
(: Import KWIC module for keyword in context display :)
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
(: Namespaces used by query :)
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";

(:
Running notes:
add search limit by speaches
limit speaches by speaker

Add map to search, may help with facets. 

:)
(: Variables :)
declare variable $search:term {request:get-parameter('term','') cast as xs:string};
declare variable $search:field {request:get-parameter('field','') cast as xs:string};
declare variable $search:start {request:get-parameter('start',1) cast as xs:integer};
declare variable $search:records {request:get-parameter('records',10) cast as xs:integer};
declare variable $search:fq {request:get-parameter('fq','') cast as xs:string};

(:~
 : Build browse function for shakespeare plays
 : may be better off using only full text queries, not range, as the taging of every word does odd things to range index
 : NOTE add sort options
 : NOTE need to build facets
 add jump to scene, and hit hightlighting in document if go from search
:)
declare function search:build-search-path(){
    if($search:field != '') then 
        if($search:field = 'title') then concat('//tei:titleStmt/tei:title[ft:query(.,"',$search:term,'")]')
        else if($search:field = 'sp') then concat('//tei:sp[ft:query(.,"',$search:term,'")]')
        else if($search:field = 'stage') then concat('//tei:stage[ft:query(.,"',$search:term,'")]')
        else ()
    else concat('//xqi:fulltext[ft:query(.,"',$search:term,'")]')   
};

declare function search:build-facet-path(){
    if($search:field != '') then 
        if($search:field = 'title') then concat('ancestor::tei:TEI/tei:titleStmt/tei:title[ft:query(.,"',$search:term,'")]')
        else if($search:field = 'sp') then concat('ancestor::tei:TEI/descendant::*/tei:sp[ft:query(.,"',$search:term,'")]')
        else if($search:field = 'stage') then concat('ancestor::tei:TEI//tei:stage[ft:query(.,"',$search:term,'")]')
        else ()
    else concat('ancestor::tei:TEI/xqi:fulltext[ft:query(.,"',$search:term,'")]')   
};


declare function search:simple() as node()*{
    let $path := concat("collection('/db/apps/xq-institute/data')",search:build-search-path())
    let $hits := util:eval($path)
    let $total-hits := count($hits)
    return
    <div>
        <div>{search:paging($hits, $total-hits)}</div>
        {
         for $hit at $p in subsequence($hits, $search:start, $search:records)
         let $uri := base-uri($hit)
         let $title := doc($uri)//tei:titleStmt/tei:title/text()
         let $scene := if($search:field = 'stage') then <div>{$hit/parent::*/tei:div1/text()}</div> else ()
         return 
             <div><span class="title"><a href="play.html?uri={encode-for-uri($uri)}">{$title}</a> [{$uri}]</span>
                {$scene}
                 <blockquote><p>{subsequence(kwic:summarize($hit, <config width="40"/>),1,3)}</p></blockquote>
             </div>
        }
     </div>   
};

(:~
 : Build paging function for search results
 : @param $search:start passed from url
 : @param $hits passed from search:simple()
 : NOTE add test to deactive next and prev if at begining or end
:)
declare function search:paging($hits as node()*, $total-hits as xs:integer*){
(: get all parameters to pass to paging function, minus start param :)
let $url-params := replace(request:get-query-string(), '&amp;start=\d+', '')
let $start := if($search:start) then $search:start else 1
let $next :=  <a href="{concat('?', $url-params, '&amp;start=', ($search:start + $search:records))}">Next</a>
let $prev :=  <a href="{concat('?', $url-params, '&amp;start=', ($search:start - $search:records)) }">Prev</a>
let $end := 
    if ($total-hits lt $search:records) then 
        $total-hits
    else 
        if(($start + $search:records)  - 1 gt $total-hits) then $total-hits
        else ($start + $search:records)  - 1
let $field-name := 
    if($search:field = 'sp') then 'speech'
    else if($search:field = 'stage') then 'stage directions'
    else if($search:field = 'title') then 'title'
    else 'keywords'
return 
 <div class="row">
    <div class="col-md-6">
       <h4>{$total-hits} results for: <span class="label label-info">{$search:term}</span> {if($search:field) then concat(' in ',$field-name) else ''}</h4> 
    </div>
    <div class="col-md-6">
        <ul class="pagination">
            <li>
            {
                if(($start - $search:records) lt 1) then <a href="#" class="disabled">Prev</a> 
                else $prev
                }
            </li>
            <li><a href="#">{$search:start} to {$end} of {$total-hits} </a></li>
            <li>
            {
             if($start + $search:records lt $total-hits) then $next 
                    else <a href="#" class="disabled">Next</a>
            }
            </li>
        </ul>
    </div>
 </div>
};

declare %templates:wrap function search:display-results($node as node(), $model as map(*)){
let $query-string := search:build-facet-path()
return
 if($search:term !='') then  
    <div class="row">
        <div class="col-md-4">
            {facets:facets($query-string)}
        </div>
        <div class="col-md-8">
            <div class="panel" >
                {search:simple()}
            </div>
        </div>
    </div>
 else ()
};
