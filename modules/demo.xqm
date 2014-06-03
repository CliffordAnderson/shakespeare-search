xquery version "3.0";

module namespace demo="http://xqueryinstitute.org/demo";

(: Some simple utility functions used in the demos.
 :
 : Okay, to ignore the "unused" warnings displayed in eXide (they are actually
 : needed in the larger template context).
 :)
import module namespace templates = "http://exist-db.org/xquery/templates" ;

(: Config module imported into project at point of creation :)
import module namespace config = "http://localhost:8080/exist/apps/xq-institute/config";

(: FunctX functions module imported into project at point of creation :)
import module namespace functx = "http://www.functx.com";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function demo:hello($node as node(), $model as map(*), $lang as xs:string*) as element(div) {
    let $langCode :=
        if (exists($lang[. ne ''])) then
            if (count($lang) > 1 or contains($lang, ','))
            then demo:simple-lang-parse($lang)
            else $lang
        else demo:simple-lang-parse(request:get-header('Accept-Language'))
    return
        <div>{
            switch($langCode)
                case "fr" return
                    "Bonjour!"
                case "de" return
                    "Hallo!"
                case "it" return
                    "Ciao!"
                case "es" return
                    "Hola!"
                default return
                    "Hello!"
        }</div>
};

declare %templates:default('lang', 'it')
function demo:hello-wrapper($node as node(), $model as map (*), $lang as xs:string) as element(div) {
    demo:hello($node, $model, $lang)
};

declare function demo:get-path($node as node(), $model as map(*), $path as xs:string) as element(span) {
    demo:span($path)
};

declare function demo:get-resource($node as node(), $model as map(*), $resource as xs:string) as element(span) {
    demo:span($resource)
};

declare function demo:get-controller($node as node(), $model as map(*), $controller as xs:string) as element(span) {
    demo:span($controller)
};

declare function demo:get-prefix($node as node(), $model as map(*), $prefix as xs:string) as element(span) {
    demo:span($prefix)
};

declare %templates:default('root', 'xmldb:exist:///db/apps')
function demo:get-root($node as node(), $model as map (*), $root as xs:string) as element(span) {
    demo:span($root)
};

declare function demo:span($variable as xs:string) as element(span) {
    <span class="green">[ {$variable} ]</span>
};

(: Just a simple demo function that parses out a language code (in an order of preference).
 : 
 : Example input: en-US,en;q=0.8,ar;q=0.6
 :)
declare function demo:simple-lang-parse($langsInput as xs:string+) as xs:string {
    let $langs :=
        for $lang in $langsInput
        return
            for $token in tokenize($lang, ',')
            return functx:trim(
                if (contains($token, ';')) then substring-before($token, ';')
                else $token
            )
    return
        if ($langs[. = 'fr']) then 'fr'
        else if ($langs[. = 'de']) then 'de'
        else if ($langs[. = 'es']) then 'es'
        else if ($langs[. = 'it']) then 'it'
        else 'en'
};

declare function demo:browse-works($node as node(), $model as map(*)) as map(*) {
    map { 'works' := collection($config:app-root || '/data/plays')//tei:titleStmt }
};

declare %templates:wrap
function demo:get-title($node as node(), $model as map(*)) as xs:string {
    $model('tei:titleStmt')/tei:title/string()
};

declare %templates:wrap
function demo:get-author($node as node(), $model as map(*)) as xs:string {
    'By: ' || $model('tei:titleStmt')/tei:author/string()
};

declare function demo:say-hello($node as node(), $model as map(*), $name as xs:string) as element(div) {
    <div>Hello, {$name}, thanks for introducing yourself!</div>
};

declare function demo:introduce($node as node(), $model as map(*)) as element(div) {
    <div>Hello, what is your name?</div>
};

