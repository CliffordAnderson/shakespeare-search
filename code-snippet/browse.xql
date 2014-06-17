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


declare function local:browse-collections($collection as xs:string) as node()*{
    for $play in collection($collection)
    let $title := $play//tei:titleStmt/tei:title/text()
    let $uri := base-uri($play)
    return 
     <li>
        <span class="title">{$title}.</span> {$uri}
    </li>
};

declare function local:browse-collections-xmldb($collection as xs:string) as node()*{
    for $play-name in xmldb:get-child-resources($collection)
    let $uri := concat($collection,'/',$play-name)
    let $title := doc($uri)//tei:titleStmt/tei:title/text()
    return 
     <li>
        <span class="title">{$title}.</span> {$uri}
    </li>
};

<ul>
    {
        let $collection := '/db/apps/xq-institute/data/plays'
        return local:browse-collections-xmldb($collection)
    }
</ul>
