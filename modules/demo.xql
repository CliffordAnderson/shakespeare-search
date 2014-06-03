xquery version "3.0";

(: declare namespace request = "http://exist-db.org/xquery/request"; :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=html5 media-type=text/html";

<html>
    <head>
        <title>Demo Live Coding Page</title>
    </head>
    <body>
        <p style="padding: 15px;">{
            for $play in collection('/db/apps/xq-institute/data/plays')
            return 
                <div>
                    <div>{$play//tei:titleStmt/tei:title/text()}</div>
                    <div>{$play//tei:titleStmt/tei:author/text()}</div>
                </div>
        }</p>
    </body>
</html>