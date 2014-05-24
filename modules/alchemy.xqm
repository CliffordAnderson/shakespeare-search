xquery version "3.0";

module namespace alchemy="http://localhost:8080/exist/apps/xq-institute/alchemy";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/xq-institute/config" at "config.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:
 : Use httpclient to send data to AlchemyAPI for text anlysis.
 : For local installations you can not use the html APIs, must use the text API
 : text API seems to have a character limitation. 
:)
declare %templates:wrap function alchemy:get-tone($node as node(), $model as map(*)){
    let $doc-url := request:get-parameter('uri', '')
    let $rec := xmldb:document($doc-url)
    for $act in $rec//tei:div1[@type='act']
    let $fulltext := string-join($act/descendant::*/tei:w/text(),' ')
    let $text := encode-for-uri(substring($fulltext,1,4500))
    let $alchemy-tone := concat('http://access.alchemyapi.com/calls/text/TextGetTextSentiment?apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',$text)
    let $alchemy-concept := concat('http://access.alchemyapi.com/calls/text/TextGetRankedConcepts?apikey=790fed0a9807d70e537757bdfbd2904cc17d6c1b&amp;text=',$text)
    let $http-tone := httpclient:get(xs:anyURI($alchemy-tone), true(), <Headers/>)
    let $http-concept := httpclient:get(xs:anyURI($alchemy-concept), true(), <Headers/>)
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
                      <div><strong>Sentiment:</strong> {$http-tone//*:docSentiment}</div>
                      <div><strong>Concepts:</strong>
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
                    </div>
                </div>
            </div>
        </div>

   
};