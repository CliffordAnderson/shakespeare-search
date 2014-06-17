xquery version "3.0";
(:~
 :  Simple code snippets for browsing the database 
 :)
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

declare function local:send-tweet ($username as xs:string,$password as xs:string,$tweet as xs:string )  as xs:boolean {
   let $uri :=  xs:anyURI("http://twitter.com/statuses/update.xml")
   let $content :=concat("status=", encode-for-uri($tweet))
   let $headers := 
      <headers>
          <header name="Authorization" 
                  value="Basic {util:string-to-binary(concat($username,":",$password))}"/>
         <header name="Content-Type"
                  value="application/x-www-form-urlencoded"/>
     </headers>
   let $response :=   httpclient:post( $uri, $content, false(), $headers ) 
   return
        $response/@statusCode='200'
 };
 
 declare function local:expath-http(){
 <http-request method="post" mime-type="text/xml" charset="utf-8">
   <header name="Header-Name">...</header>
   <header name="Header2-Name">...</header>
   <body>
      The textual value of body will be the payload of the HTTP request...
   </body>
</http-request>
 };
 
 let $username := 'xqy14'
 let $password := 'xq4dh14'
 let $tweet := 'tweet'
 return local:send-tweet($username,$password,$tweet)
 