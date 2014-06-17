xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

(: contstructed field examples for our data:)
 
for $doc-index in collection('/db/apps/xq-institute/data/indexed-plays')
let $uri := base-uri($doc-index)
let $doc := xmldb:document($uri) 
return 
ft:index($uri, <doc>
    <field name="xqeditor" store="yes">Winona Salesky</field>
</doc>)


(: Query constructed field :)
(:  
for $result in //ft:search('xqeditor:winona')/search
let $fields := $result/field
let $uri := $result/@uri
let $title := doc($uri)//tei:titleStmt/tei:title/text()
return 
        <result>
            <title>{$title}</title>
            <hit>{$fields}</hit>
        </result>
        
        :)