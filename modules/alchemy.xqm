xquery version "3.0";

module namespace alchemy="http://xqueryinstitute.org/alchemy";

(:
 : Use httpclient to send data to AlchemyAPI for text analysis.
 : For local installations you can not use the html APIs, must use the text API
 : text API seems to have a character limitation. 
:)

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function alchemy:build-tone-node($fulltext as xs:string?) as node()*{
    let $text := encode-for-uri(substring($fulltext,1,4500))
    let $alchemy-tone := concat('http://access.alchemyapi.com/calls/text/TextGetTextSentiment?apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',$text)
    let $http-tone := httpclient:get(xs:anyURI($alchemy-tone), true(), <Headers/>)
    return 
        <div><strong>Sentiment: </strong> {$http-tone//*:docSentiment}</div>
};
declare function alchemy:build-concept-node($fulltext as xs:string?) as node()*{
    let $text := encode-for-uri(substring($fulltext,1,4500))
    let $alchemy-concept := concat('http://access.alchemyapi.com/calls/text/TextGetRankedConcepts?apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',$text)
    let $http-concept := httpclient:get(xs:anyURI($alchemy-concept), true(), <Headers/>)
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
                        {(alchemy:build-tone-node($fulltext), alchemy:build-concept-node($fulltext))}
                     </div>           
                </div>
            </div>
        </div>
};