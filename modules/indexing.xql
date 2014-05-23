xquery version "3.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";


(:~
 : Add fulltext fields for faster indexing. 
 : Uses locally defined namespace to differentiate between local and tei elements
 : If using in production would have to add a trigger to rerun when documents are updated.
:)
for $doc-index in collection('/db/apps/xq-institute/data')
let $uri := base-uri($doc-index)
let $doc := xmldb:document($uri) 
let $fulltext := 
    <fulltext xmlns="http://xqueryinstitute.org/ns">
        {
            for $word in  $doc//tei:body/descendant::*/tei:w/text()
            return concat($word,' ')
        }
    </fulltext>
let $change-log :=
    <change xmlns="http://www.tei-c.org/ns/1.0" who="http://xqueryinstitute.org/wsalesky" when="{current-date()}">
        Added local fields fulltext, speech, and stage for fulltext searching. For: XQueryInstitute
    </change>   
return 
    (:"Don't run this now":)
    (:
    if($doc//xqi:fulltext) then 
        try {
                (
                    update replace $doc/xqi:fulltext with $fulltext,
                    update replace $doc/xqi:speech with $fulltext-speech,
                    update replace $doc/xqi:stage with $fulltext-stage,
                    update insert $change-log preceding $doc//tei:teiHeader/tei:revisionDesc/tei:change[1],
                    update value $doc//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
                    )
             } catch * {
                         <p>{
                             ("Error:", $err:code)
                         }</p>
                     }
    else 
        try {
            (
                update insert $fulltext following $doc//tei:text[last()],
                update insert $fulltext-speech following $doc//tei:text[last()],
                update insert $fulltext-stage following $doc//tei:text[last()],
                update insert $change-log preceding $doc//tei:teiHeader/tei:revisionDesc/tei:change[1],
                update value $doc//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
                )
         } catch * {
                     <p>{
                         ("Error:", $err:code)
                     }</p>
                 } 
                 
              :)
              
 (:End updates:)             
    
(:~ 
 : Add constructed fields to index for more efficient searching 
xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";

for $doc-index in collection('/db/apps/xq-institute/data')
let $uri := base-uri($doc-index)
let $doc := xmldb:document($uri) 

return 
ft:index($uri, <doc>
    <field name="play" store="yes">
       {
            for $word in  $doc//tei:body/descendant::*/tei:w/text()
            return concat($word,' ')
        }
    </field>
</doc>)

):)

