xquery version "3.0";

module namespace alchemy="http://xqueryinstitute.org/alchemy";
(:~
 : Add data from the AlchemyAPI to each act in each play. 
 : @author Winona Salesky
 : @version 0.1
:)
(:
 : Import modules needed for eXist templating
:)
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace http="http://expath.org/ns/http-client";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function alchemy:build-headers() as node(){
   <headers>
     <header name="Content-Type" value="application/x-www-form-urlencoded"/>
   </headers>
};

(:~
 : Querying the Alchemy API using httpclient:post()
 : @fulltext text passed from play record
:)
declare function alchemy:build-tone-node($fulltext as xs:string?) as element()*{
    let $text := concat('apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',encode-for-uri(substring($fulltext,1,4500)))
    let $alchemy-uri := 'http://access.alchemyapi.com/calls/text/TextGetTextSentiment'
    let $http-tone := httpclient:post(xs:anyURI($alchemy-uri), $text, true(), alchemy:build-headers())
    return 
        <div><strong>Sentiment: </strong> {$http-tone//*:docSentiment}</div>
};

(:~
 : Querying the Alchemy API using http:send()
 : Recommended over httpclient
 : @fulltext text passed from play record
:)
declare function local:expath-http($fulltext as xs:string?) as node()*{
    let $text := concat('apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',encode-for-uri(substring($fulltext,1,4500)))
    let $alchemy-uri := 'http://access.alchemyapi.com/calls/text/TextGetTextSentiment'
    let $http-tone := httpclient:post(xs:anyURI($alchemy-uri), $text, true(), alchemy:build-headers())
    let $build-request :=
         <http:request href="{$alchemy-uri}" method="post">
            <http:body media-type="application/x-www-form-urlencoded">{$text}</http:body>
        </http:request>
    let $request := http:send-request($build-request, $alchemy-uri)
    return 
    <div><strong>Sentiment2: </strong> {$http-tone//*:docSentiment}</div>
 };
 
 (:~
 : Querying the Alchemy API using httpclient:post()
 : @fulltext text passed from play record
:)
declare function alchemy:build-concept-node($fulltext as xs:string?) as node()*{
    let $text := concat('apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',encode-for-uri(substring($fulltext,1,4500)))
    let $alchemy-uri := 'http://access.alchemyapi.com/calls/text/TextGetRankedConcepts'
    let $http-concept := httpclient:post(xs:anyURI($alchemy-uri), $text, true(), alchemy:build-headers())
    return 
         <div><strong>Concepts: </strong>
            <dl class="offset1" style="margin-left: 1em;">
                {
                    for $node in $http-concept//*:concept
                    return 
                        (
                            <dt style="font-weight:600; color: #666;">{$node/*:text} {$node/*:relevance}</dt>,
                              if($node/*:dbpedia) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:dbpedia}">{$node/*:dbpedia}</a></dd>
                              else '',
                              if($node/*:yago) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:yago}">{$node/*:yago}</a></dd>
                              else '',
                              if($node/*:opencyc) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:opencyc}">{$node/*:opencyc}</a></dd>
                              else '',
                              if($node/*:freebase) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:freebase}">{$node/*:freebase}</a></dd>
                              else '',
                              if($node/*:ciaFactbook) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:ciaFactbook}">{$node/*:ciaFactbook}</a></dd>
                              else '',
                              if($node/*:census) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:census}">{$node/*:census}</a></dd>
                              else '',
                              if($node/*:crunchbase) then 
                                 <dd class="offset1" style="margin-left: 1em;"><a href="{$node/*:crunchbase}">{$node/*:crunchbase}</a></dd>
                              else '')
                 }
            </dl>
         </div>
};

(:~
 : Build results display
 : @rec record to analyze
:)
declare function alchemy:get-tone($rec as node()){
    for $act in $rec//tei:div1[@type='act']
    let $fulltext := string-join($act/descendant::*/tei:w/text(),' ')
    let $text := encode-for-uri(substring($fulltext,1,4500))
    let $alchemy-tone := concat('http://access.alchemyapi.com/calls/text/TextGetTextSentiment?apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',$text)
    return 
        <div class="panel-group" id="accordion2">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">
                        <a data-toggle="collapse" data-parent="#accordion" href="#{concat('act',$act/@n)}">{concat('Act ',$act/@n)}</a>
                    </h4>
                </div>
                <div id="{concat('act',$act/@n)}" class="panel-collapse collapse in">
                    <div class="panel-body">
                        {(local:expath-http($fulltext),alchemy:build-tone-node($fulltext), alchemy:build-concept-node($fulltext))}
                     </div>           
                </div>
            </div>
        </div>
};