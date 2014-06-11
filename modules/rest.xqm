xquery version "3.0";

module namespace demo = "http://xqueryinstitute.org/demo";

import module namespace req="http://exquery.org/ns/request";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rest = "http://exquery.org/ns/restxq";

(:
declare option output:method "json";
declare option output:media-type "application/json";
:)


declare
    %rest:GET
    %rest:path("/page")
    %output:media-type("text/html")
    %output:method("html5")
function demo:restfultest() {
    <html>yada</html>
};

