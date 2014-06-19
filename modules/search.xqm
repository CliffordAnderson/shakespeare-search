xquery version "3.0";
(: module namespace :)
module namespace search="http://xqueryinstitute.org/search";
(:~
 : Build fielded search 
 : @author Winona Salesky
 : @version 0.1
:)

(: Templating modules :)
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";
import module namespace facets="http://xqueryinstitute.org/facets" at "facets.xqm";
(: Import KWIC module for keyword in context display :)
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
(: Namespaces used by query :)
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";

(: Parameters :)
declare variable $search:term {request:get-parameter('term','') cast as xs:string};
declare variable $search:field {request:get-parameter('field','') cast as xs:string};
declare variable $search:start {request:get-parameter('start',1) cast as xs:integer};
declare variable $search:records {request:get-parameter('records',10) cast as xs:integer};
(: Facet parameters:)
declare variable $search:play {request:get-parameter('play','') cast as xs:string};
declare variable $search:speaker {request:get-parameter('speaker','') cast as xs:string};
declare variable $search:genre {request:get-parameter('genre','') cast as xs:string};
declare variable $search:performed {request:get-parameter('performed','') cast as xs:string};
declare variable $search:date {request:get-parameter('date','') cast as xs:string};

(:~
 : Constructs search string for evaluation
 : NOTE retool to add query node
:)
declare function search:build-search-path(){
if($search:field != '') then 
        if($search:field = 'title') then 
            concat("//tei:titleStmt/tei:title[ft:query(.,'",$search:term,"')]")
        else if($search:field = 'sp') then 
            concat("//tei:sp[ft:query(.,'",$search:term,"')]")
        else if($search:field = 'stage') then 
            concat("//tei:stage[ft:query(.,'",$search:term,"')]")
        else ()
    else concat("//tei:body[ft:query(.,'",$search:term,"')]")  
};

(:~
 : Add facets to search string to narrow results
:)
declare function search:add-facets() as xs:string*{
let $title-facet :=
    if($search:play) then
        concat("[ancestor::tei:TEI//tei:titleStmt/tei:title"," = '",$search:play,"']")
    else ()
let $speaker-facet :=    
    if($search:speaker) then
        concat("[ancestor::tei:TEI//tei:speaker"," = '",$search:speaker,"']")
    else ()
let $genre-facet :=    
    if($search:genre) then
        concat("[ancestor::tei:TEI//xqi:genre"," = '",$search:genre,"']")
    else ()
let $performed-facet :=   
    if($search:performed) then
        concat("[ancestor::tei:TEI//xqi:performed"," = '",$search:performed,"']")
    else ()
let $date-facet :=    
    if($search:date) then
        concat("[ancestor::tei:TEI//tei:date"," = '",$search:date,"']")
    else ()
return 
    concat($title-facet,$speaker-facet,$genre-facet,$performed-facet,$date-facet) 
};

(:
 : Build facet text to display on search results page
:)
declare function search:decode-facets() as xs:string*{
let $title-facet :=
    if($search:play) then
        concat("Title: ",$search:play," ")
    else ()
let $speaker-facet :=    
    if($search:speaker) then
        concat("Speaker: ",$search:speaker," ")
    else ()
let $genre-facet :=    
    if($search:genre) then
        concat("Genre: ",$search:genre," ")
    else ()
let $performed-facet :=   
    if($search:performed) then
        concat("Performed: ",$search:performed," ")
    else ()
let $date-facet :=    
    if($search:date) then
        concat("Date: ",$search:date," ")
    else ()
return 
    concat($title-facet,$speaker-facet,$genre-facet,$performed-facet,$date-facet)
};

(:~
 : Helper function: create a lucene query from the user input
 : Tests for quotes in input to create phrase or near matches
 : This is an example only, it is not used in the search
:)
declare %private function search:create-query() {
    <query>
        {
            if (starts-with($search:term,'"')) then
                <phrase>{$search:term}</phrase>
            else
                <near>{$search:term}</near>
        }
    </query>
};

(:~
 : Function developed by @joewiz for faster rendering of KWIC 
:)
declare function search:milestone-chunk(
     $ms1 as element(),
     $ms2 as element(),
     $node as node()*) as node()*
{
    typeswitch ($node)
    case element() return
        if ($node is $ms1) then
            $node
        else if ( some $n in $node/descendant::* satisfies ($n is $ms1 or $n is $ms2) ) then
            element { name($node) }
                {
                for $i in ( $node/node())
                return
                    search:milestone-chunk($ms1, $ms2, $i)
                }
        else if ( $node >> $ms1 and $node << $ms2 ) then
            $node
        else ()
    default return
        if ( $node >> $ms1 and $node << $ms2 ) then
            $node
        else ()
};

(:~
 : Function developed by @joewiz for faster rendering of KWIC 
:)
declare function search:trim-matches($node, $keep) {
let $matches := $node//exist:match
return
    if (count($matches) le $keep) then
        $node
    else
        search:milestone-chunk(subsequence($matches, 1, 1), subsequence($matches, $keep, 1), $node)
};


(:~
 : Output search results using KWIC
 : NOTE would be nice to add a link to scene, or to hit within the play
:)
declare function search:simple() as node()*{
    let $path := concat("collection('/db/apps/xq-institute/data/indexed-plays')",search:build-search-path(),search:add-facets())
    let $hits := util:eval($path)
    let $total-hits := count($hits)
    return
       <div class="row">
         <div class="col-md-4">
         {facets:facets($hits)}
         </div>
         <div class="col-md-8">
             <div class="panel" >
                 <div>
                    {search:paging($hits, $total-hits)}
                </div>
                {
                 for $hit at $p in subsequence($hits, $search:start, $search:records)
                 let $get-uri := base-uri($hit)
                 let $uri := replace($get-uri,'/indexed-plays','/plays')
                 let $title := $hit/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
                 let $matches-to-highlight := 2
                 let $trimmed-hit := search:trim-matches(util:expand($hit),$matches-to-highlight)
                 let $summary := kwic:summarize($trimmed-hit, <config xmlns="" width="60"/>)
                 return 
                     <div><span class="title"><a href="play.html?uri={encode-for-uri($uri)}">{$title}</a></span>
                        <blockquote><p>{$summary}</p></blockquote>
                     </div>
                }
             </div> 
         </div>
      </div>        
};

(:~
 : Build paging function for search results
 : @param $search:start passed from url
 : @param $hits passed from search:simple()
 : NOTE add test to deactive next and prev if at begining or end
:)
declare function search:paging($hits as node()*, $total-hits as xs:integer*) as node(){
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
       <div class="title">{$total-hits} results for: <span class="label label-info">{$search:term}</span> 
       {if($search:field) then concat(' in ',$field-name) else ''}
        <span class="title">
            {search:decode-facets()}
        </span>
       </div> 
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

(:~
 : Pass search results to search.html 
:)
declare %templates:wrap function search:display-results($node as node(), $model as map(*)){
 if($search:term !='') then  
    search:simple()
 else ()
};