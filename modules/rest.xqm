xquery version "3.0";

module namespace demo = "http://xqueryinstitute.org/demo";

import module namespace req="http://exquery.org/ns/request";

(: For output annotations :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: For REST annotations :)
declare namespace rest = "http://exquery.org/ns/restxq";

(: For interacting with the TEI document :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";


declare
    %rest:GET
    %rest:path("/shakespeare/plays")
    %output:media-type("text/html")
    %output:method("html5")
function demo:get-plays-html() {
    demo:htmlify(demo:list-plays())
};

declare function demo:htmlify($plays) {
    <html>
        <head>
            <title>Simple List of Plays</title>
        </head>
        <body>
            <p style="padding: 15px;">
                <table width="33%">
                    <tr>
                        <th style="text-align:left">Title</th>
                        <th style="text-align:left">Author</th>
                    </tr>
                    {
                    for $play in $plays
                    return 
                        <tr>
                            <td>{$play/title/text()}</td>
                            <td>{$play/author/text()}</td>
                        </tr>
                    }
                </table>
            </p>
        </body>
    </html>
};

declare function demo:list-plays() {
    for $play in collection('/db/apps/xq-institute/data/plays')
    return 
        <play>
            <title>{$play//tei:titleStmt/tei:title/text()}</title>
            <author>{$play//tei:titleStmt/tei:author/text()}</author>
        </play>
};


