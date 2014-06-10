xquery version "3.0";
(:~
 :  jsonouput for timelinejs  
 :)

declare namespace xslt="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace json="http://www.json.org";

declare option exist:serialize "method=json media-type=text/javascript encoding=UTF-8";

<json>
<timeline>
    <headline>Shakespeare's plays</headline>
    <type>default</type>
    <text></text>
    <asset>
        <media>http:localhost</media>
        <credit>wsalesky</credit>
        <caption>Dates generated from  http://www.shakespeare-online.com/keydates/playchron.html </caption>
    </asset>
    {
    for $play in collection('/db/apps/xq-institute/data/indexed-plays')
    let $title := $play//tei:fileDesc/tei:titleStmt/tei:title/text()
    let $pubDate := $play//tei:witness/tei:date/text()
    let $first-performed := $play//xqi:performed/text()
    return
        <date json:array="true">
            <startDate>{$pubDate}</startDate>
            <endDate>{$pubDate}</endDate>
            <headline>{$title}</headline>
            <text>Published: {$pubDate} &lt;br/&gt; First performed: {$first-performed}</text>
        </date>
  }
 </timeline> 
</json>