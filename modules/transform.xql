xquery version "3.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";
(:~
 : Add fulltext fields for faster indexing. 
 : Uses locally defined namespace to differentiate between local and tei elements
 : If using in production would have to add a trigger to rerun when documents are updated.
 NOTE: add in dates
 re-index, change xqueries to use new index. 
:)


(xmldb:login('/db/apps/xq-institute','admin',''),
for $doc-index in collection('/db/apps/xq-institute/data/plays')
let $uri := base-uri($doc-index)
let $doc := xmldb:document($uri)/tei:TEI
let $doc-name := util:document-name($doc)
let $newDoc := transform:transform($doc, doc('../resources/xsl/tei-to-tei.xsl'),() )
return 
    xmldb:store('/db/apps/xq-institute/data/indexed-plays', $doc-name, $newDoc))
  