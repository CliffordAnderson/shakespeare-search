xquery version "3.0";
(:~
 :  Simple code snippets for browsing the database 
 :)
declare namespace tei="http://www.tei-c.org/ns/1.0";
(:
xquery 1.0 
declare option exist:serialize "method=html5 media-type=application/xhtml+xml encoding=utf-8 indent=yes"; 
declare option exist:serialize "method=json media-type=text/javascript encoding=UTF-8";
:)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "application/xhtml+xml";



<ul>
    {
        for $hits in collection('/db/apps/xq-institute/data/indexed-plays')//tei:sp[ft:query(.,'pox')]
        let $title := $hits/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
        return
            <li>{$title}</li>
    }
</ul>