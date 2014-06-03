xquery version "3.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xqi="http://xqueryinstitute.org/ns";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

(:~
 : Add dates from an external source to each tei record. 
:)
declare function local:get-genre($plays){
let $url := 'http://www.opensourceshakespeare.org/views/plays/plays.php'
let $http-get-data := httpclient:get(xs:anyURI($url), true(), <Headers/>)
let $comedies := string-join($http-get-data//*:td[contains(descendant::*:h3,'COMEDIES')]/descendant::*:a/node())
let $tragedies := string-join($http-get-data//*:td[contains(descendant::*:h3,'TRAGEDIES')]/descendant::*:a/node())
let $histories := $http-get-data//*:td[contains(descendant::*:h3,'HISTORIES')]/descendant::*:a/node()
let $uri := base-uri($plays)
let $title := $plays/text()
let $doc := xmldb:document($uri)
return 
    if(contains($comedies,$title)) then 
        update insert 
            <genre xmlns="http://xqueryinstitute.org/ns">comedy</genre>
            following $doc//tei:text[last()]    
    else if(contains($tragedies,$title)) then 
        update insert 
            <genre xmlns="http://xqueryinstitute.org/ns">tragedy</genre>
            following $doc//tei:text[last()]    
    else if(contains($histories,$title)) then 
        update insert 
            <genre xmlns="http://xqueryinstitute.org/ns">history</genre>
            following $doc//tei:text[last()]    
    else ''

};

declare function local:attribute-changes(){
        <change xmlns="http://www.tei-c.org/ns/1.0" who="http://xqueryinstitute.org/wsalesky" when="{current-date()}">
        Added additional tei:witness for original publication date to tei:source, Added xqi:performed for first performance date, and xqi:genre for play genre. Source: http://www.opensourceshakespeare.org/views/plays/plays.php  For: XQueryInstitute
    </change>     
};

declare function local:get-dates($plays){
let $url := 'http://www.shakespeare-online.com/keydates/playchron.html'
let $http-get-data := httpclient:get(xs:anyURI($url), true(), <Headers/>) 
let $uri := base-uri($plays)
let $title := $plays/text()
let $doc := xmldb:document($uri)
return  
    for $play in $http-get-data//*:TABLE[contains(descendant::*:TH,'First Performed')]/descendant::*/*:TR
    let $inlinetitle := $play/*:TD[2]/*:a/text()
    let $published := $play/*:TD[3]/text()
    let $performed := $play/*:TD[1]/text()
    return 
        if(contains($title,$inlinetitle)) then 
            if($published != '') then
            (
            update insert 
            <witness xml:id="shakespeare-online" xmlns="http://www.tei-c.org/ns/1.0">
                <date>{$published}</date>
                <ptr target="http://www.shakespeare-online.com/keydates/playchron.html"/>
            </witness>
                into $doc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit, 
            update insert 
                <performed xmlns="http://xqueryinstitute.org/ns">{$performed}</performed> following $doc//tei:text[last()], 
            update insert local:attribute-changes() preceding $doc//tei:teiHeader/tei:revisionDesc/tei:change[1],
            update value $doc//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date with current-date()
            )
            else ''
        else ''    
};

for $plays in collection('/db/apps/xq-institute/data/indexed-plays')//tei:titleStmt/tei:title
return (local:get-dates($plays),local:get-genre($plays))
    

  