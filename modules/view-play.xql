xquery version "3.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(:~ 
 : Parameters passed from the url 
 : @param $id passes internal id for play
 : @param $view view used for output
 :)
declare variable $uri {request:get-parameter('uri', '')};
declare variable $view {request:get-parameter('view', '')};

let $rec := xmldb:document($uri)
return 
    if($view = 'html') then transform:transform($rec, doc('../resources/xsl/teiHTML.xsl'),() )
    else if($view = 'pdf') then transform:transform($rec, doc('../resources/xsl/editions-pdf.xsl'),() )
    else $rec/child::*