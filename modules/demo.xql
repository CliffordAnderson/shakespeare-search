xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace rest = "http://exquery.org/ns/restxq";

declare option exist:serialize "method=html5 media-type=text/html";

<html>
    <head>
        <title>Stored XQuery Example</title>
    </head>
    <body>
        <p style="padding: 15px;">
            <table width="33%">
                <tr>
                    <th style="text-align:left">Title</th>
                    <th style="text-align:left">Author</th>
                </tr>
                {
                for $play in collection('/db/apps/xq-institute/data/plays')
                return 
                    <tr>
                        <td>{$play//tei:titleStmt/tei:title/text()}</td>
                        <td>{$play//tei:titleStmt/tei:author/text()}</td>
                    </tr>
                }
            </table>
        </p>
        <p>{
            rest:resource-functions()
        }</p>
    </body>
</html>