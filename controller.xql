xquery version "3.0";

(: Controller variables available to you to help route requests :)
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>

(: Handles the default directory request :)
else if ($exist:path eq "/") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

(: An example of the variables passed into the controller.xql :)
else if ($exist:resource eq "controller.html") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <!-- First two examples use an HTTP parameter -->
                <add-parameter name="path" value="{$exist:path}"/>
                <add-parameter name="resource" value="{$exist:resource}"/>
                <!-- Next two examples use an HTTP session attribute -->
                <set-attribute name="controller" value="{$exist:controller}"/>
                <set-attribute name="prefix" value="{$exist:prefix}"/>
                <!-- The last example, $exist:root, uses statically defined template default -->
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else if ($exist:resource eq 'demo') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/demo.xql"/>
    </dispatch>

(: The HTML page is run through view.xql to expand templates :)
else if (ends-with($exist:resource, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

(: This lets us reference the root in our page.html template, and have it work
 : for templates which are not at the webapp's root direction (e.g., demos dir)
 :)
else if (contains($exist:path, "/$root/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, substring-after($exist:path, '/$root'))}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

(: Everything else is just passed through :)
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
