xquery version "3.0";
(:~
 :  Simple code snippets for browsing the database 
:)


declare function local:change-doc-permissions($collection as xs:string){
    for $rec in xmldb:get-child-resources($collection)  
    let $path := concat($collection,'/',$rec)
    return
        (sm:chmod($path, 'rwxr-xr-x'), local:print-permissions($path))

};
declare function local:print-permissions($path as xs:string*){
    ($path, sm:get-permissions($path))
};
(
xmldb:login('/db/apps/xq-institute','admin',''),
local:change-doc-permissions('/db/apps/xq-institute/code-snippet')
)