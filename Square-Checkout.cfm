<cfif Compare(cgi.SERVER_PORT,443)>
<cflocation url="https://#CGI.SERVER_NAME##CGI.HTTP_URL#?#CGI.QUERY_STRING#" addtoken="no" />
</cfif>

<cfset REQUEST.location_id = "YOUR_LOCATON_ID">
<cfset REQUEST.Access_Token = "YOUR_ACCESS_TOKEN">
<cfset REQUEST.Square_Server = "connect.squareupsandbox.com">
<cfset REQUEST.Square_Version = "2020-06-25">

<cfif isDefined("URL.transactionId")>

<cfset rtFields = { 
          "order_ids": [
              "#URL.transactionId#"
          ]
}>

<cfhttp method="post" result="objGet" url="https://#REQUEST.Square_Server#/v2/locations/#REQUEST.location_id#/orders/batch-retrieve">

<cfhttpparam type="header" name="Accept" value="application/json">
<cfhttpparam type="header" name="Authorization" value="Bearer #REQUEST.Access_Token#">
<cfhttpparam type="header" name="Cache-Control" value="no-cache">
<cfhttpparam type="header" name="Content-Type" value="application/json">
<cfhttpparam type="body" value="#serializeJSON(rtFields)#">

</cfhttp>

<cfelse>

<cfset REQUEST.idempotency_key = #CreateUUID()#>
<cfset REQUEST.order_idempotency_key = #CreateUUID()#>

<!--- Copy & Paste content from inside apostrophes under -d ' CONTENT ' for cURL Type between {} here, from https://developer.squareup.com/explorer/square/checkout-api/create-checkout --->
<!--- Then replace values following ": " VALUE " as needed based to dynamtic values, as/if needed --->
<cfset stFields = {
    "idempotency_key": "#REQUEST.idempotency_key#",
    "order": {
      "idempotency_key": "#REQUEST.order_idempotency_key#",
      "order": {
        "location_id": "#REQUEST.location_id#",
        "customer_id": "MyCustomerID",
        "line_items": [
          {
            "quantity": "1",
            "name": "Item Name",
            "note": "Item Description",
            "base_price_money": {
              "amount": 100,
              "currency": "USD"
            }
          }
        ]
      }
    },
    "ask_for_shipping_address": false,
    "merchant_support_email": "consectetur@loremipsum.com",
    "redirect_url": "https://#CGI.SERVER_NAME##CGI.HTTP_URL#?#CGI.QUERY_STRING#"
  }>   

<cfhttp method="post" result="objGet" url="https://#REQUEST.Square_Server#/v2/locations/#REQUEST.location_id#/checkouts">

<cfhttpparam type="header" name="Square-Version" value="#REQUEST.Square_Version#">
<cfhttpparam type="header" name="Authorization" value="Bearer #REQUEST.Access_Token#">
<cfhttpparam type="header" name="Content-Type" value="application/json">
<cfhttpparam type="body" value="#serializeJSON(stFields)#">

</cfhttp>

</cfif>

<cfscript>
squareupdata = deserializeJSON(#objGet.FileContent#);
</cfscript>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>ColdFusion Square Checkout Example</title>
</head>
<body>

<cfif isDefined("squareupdata.checkout.checkout_page_url")>

<a href="<cfoutput>#squareupdata.checkout.checkout_page_url#</cfoutput>" target="_self">Click Here to Checkout</a>

</cfif>

<cfif isDefined("squareupdata.orders")>
<cfif StructKeyExists(squareupdata.orders[1],"state")>

<cfoutput>#squareupdata.orders[1].state#</cfoutput>

</cfif>
</cfif>

<!--- REMOVE THIS LINE IN PRODUCTION ---><br /><cfdump var="#VARIABLES#">

</body>
</html>
