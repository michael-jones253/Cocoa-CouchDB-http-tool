# Cocoa-CouchDB-http-tool
An OS X Cocoa GUI app for playing with the NoSQL CouchDB via the http API. The main app window is just a toy for getting to know the CouchDb HTTP rest API at a low level. It operates with json documents for its input/output. The replicate window is more user friendly, because it does json parsing and some checks to let the user know whether they are syncing an existing database or creating a new one.

## Motivation for this project.
Although I am mainly a back end client server/distributed systems programmer I frequently have to maintain GUIs so I thought I would get to know the OS X Cocoa interface and make a foray into some Objective-C. This app allows me to play with CouchDB via the http API which is also something I am interested in. It is based on libcurl which is good for getting to know HTTP at a low level and the json CouchDB uses. However, the replication stuff does work at a higher level with the Objective-C NSURL classes and json parsing.

This is my first go at Objective-C and I dived in to quickly get the feel for the language and also get the CouchDB project functioning. I am not doing everything using best practises, but have started to read Google's Objective-C Style guide and am just starting to refactor my code accordingly.

https://google-styleguide.googlecode.com/svn/trunk/objcguide.xml

## Structure of this project.
I am attempting to follow the MVC pattern in the following way:

1. A c++ dylib which takes the role of the 'model'. This dynamic library uses 'libcurl' to formulate the HTTP requests.
2. An Objective-C framework which calls the above dylib and acts as the 'controller'.
3. The Xcode generated Document.h/m acts as the view.

The idea is that the dylib model could be used by any application GUI or otherwise. The Controller is the what sits in between this model and the GUI view. The controller is responsible for making sure that user initiated actions and selections from the view are sent to the model in an orderly way e.g. connection initiated before setting HTTP parameters to libcurl. The controller does some parameter validation and provides any error and result feedback to the view.

I also tried to design it such that changes to the view should not require major changes to the controller.

Test driven development helps keep the application logic out of the View and in the controller where it can be tested by the test project.

## Initial impressions and grappling with Objective-C.
Once I got over the square brackets method call syntax I decided that this language is not so alien. Objective-C can be mixed with C++ so this allowed me to call the dylib from the Objective-C framework using a similar technique to a Dr Dobbs tutorial.

I had previously learned Apple's Swift language and my reaction was Swift does not have exceptions?! However, it seems that Objective-C exceptions aren't quite like what I was hoping for as a C++ programmer. I consider exception driven C++ to be the superior control flow compared to error code returns. The reason is that I have seen frequent programming mistakes where the developer has ignored the error code and the code carries on regardless of whether an error has occurred or not. It also leads to ambiguous API situations where the developer is not sure whether the code can be ignored or not. Exceptions in comparison are unequivocal. Another error that occurs is that the return code value e.g. integer is wrongly interpreted e.g. treated as a bool when -1 is intended to indicate an error.

What I am reading about Objective-C exceptions is that exceptions are only intended for programmer errors and are otherwise discouraged.

An update to my thoughts on the above exception discussion is that I still think exception based code (as opposed to error return code) is the superior form of control flow and should be used for C++, however it is best not to fight the Objective-C NSError return methodology. Many of the "Foundation" classes provided by Apple take the approach of returnign NSError objects via parameters, so passing these up the call chain is more straightforward than converting them to exceptions in an attempt to produce exception driven control flow.

## How I use this tool.

This GUI app comes with a number of controls e.g. to choose a jpeg image to upload to CouchDB , but the main ones are:
* The URL address bar where I type in the HTTP URI of a CouchDB resource.
* HTTP radio buttons where I select the HTTP method of which the following are supported: GET, POST, PUT, DELETE.
* A "go" button to execute the query.
* There are two text panels - the top one is where I enter any json for PUT and POST operations, the bottom text panel is a scrollable field which displays the response.

The "copy" button is what makes this tool useful for me - it copies the response text (json from CouchDB) into the PUT/POST window where I can edit/adjust it, then post back the updated document. Because the document revision is carried in the response and then copied back into the PUT/POST window, it is quicker to use than CURL on the command line.

e.g. If I enter "http://127.0.0.1:5984/hello/" into the URL address bar, select the "POST" button and have "{"company": "Example, Inc."}" in the data window, then press the "go" button I will create a new document in the (already existing) database named "hello" because CouchDB's REST API will consider the POST as a request to produce a new resource. The response window will show:

<pre><code>
{“ok”:true,”id”:”5a91243f72a836d475b56b20c90012ef”,”rev”:”1-b14c811bf485b30b70aab77810769d00”}
</code></pre>
I can then copy the id onto the end of the address "http://127.0.0.1:5984/hello/5a91243f72a836d475b56b20c90012ef" select the HTTP "GET" radio button and hit "go" to get:

<pre><code>
{“_id”:”5a91243f72a836d475b56b20c90012ef”,”_rev”:”1-b14c811bf485b30b70aab77810769d00”,”company”:”Example, Inc.”}
</code></pre>

Then I can use the copy button to put the document complete with id and revision back into the data window, make and adjustment e.g. alter the compnay name, select the HTTP "PUT" button and press "go". Being a REST API CouchDB treats this as an existing resource and modifies it. The _id field is actually in the URL address bar, but CouchDB ignores it. The _rev field, however is necessary otherwise CouchDB will report a document conflict. The revision requiremnet is part of CouchDB's model to ensure the integrity of document modifications.

## Map-reduce example.

I have a database which contains documents with the following data:

<pre><code>
{”shop”:”Local skate shop”,”wheels”:[50,51,52,53,54],”griptape”:true,”decks”:[8,8.25,8.5],”city”:”Melbourne”}},
{”shop”:”Internet skate shop”,”wheels”:[50,51,52,53,54,55,56,58,60],”griptape”:true,”decks”:[8,8.25,8.5,8.75],”city”:”Melbourne”}},
{”shop”:”Big skate shop”,”wheels”:[50,51,52,53,54,55,56,58,60],”griptape”:true,”decks”:[8,8.25,8.5,8.75,9],”city”:”Melbourne”}},
{”shop”:”Underground skate shop”,”wheels”:[50,51,52],”griptape”:true,”decks”:[8,8.25,8.5],”city”:”Melbourne”}},
{”shop”:”City skate shop”,”wheels”:[50,51,52,53,54],”griptape”:false,”decks”:[8,8.25,8.5],”city”:”Sydney”}},
{”shop”:”E-bay skate shop”,”wheels”:[50,51],”griptape”:false,”decks”:[8,8.5],”city”:”Sydney”}}
</code></pre>

If I POST to the URL "http://127.0.0.1:5984/hello/_design/wheels" the following json document (containing a javascript map function):
<pre><code>
{"views":{"getwheels":{"map":"function(doc){
    if(doc.shop && doc.city && doc.wheels) {
        emit(doc.city, doc.wheels);}}"}}}
</code></pre>

Then do a HTTP GET on "http://127.0.0.1:5984/hello/_design/wheels/_view/getwheels" I will get the following response:
<pre><code>
{“total_rows”:6,”offset”:0,”rows”:[
{“id”:”1fbe064c1720d7b0a46b52ec3b000f6b”,”key”:”Melbourne”,”value”:[50,51,52,53,54]},
{“id”:”1fbe064c1720d7b0a46b52ec3b002932”,”key”:”Melbourne”,”value”:[50,51,52,53,54,55,56,58,60]},
{“id”:”1fbe064c1720d7b0a46b52ec3b0029ec”,”key”:”Melbourne”,”value”:[50,51,52,53,54,55,56,58,60]},
{“id”:”5a91243f72a836d475b56b20c9000a18”,”key”:”Melbourne”,”value”:[50,51,52]},
{“id”:”1fbe064c1720d7b0a46b52ec3b001b60”,”key”:”Sydney”,”value”:[50,51,52,53,54]},
{“id”:”1fbe064c1720d7b0a46b52ec3b002e46”,”key”:”Sydney”,”value”:[50,51]}
]}
</code></pre>

This is an example of a "map" operation and it returns all the skateboard wheel diameters (traditionally in mm) for all documents that describe skate shops. i.e. documents that have the pre-requesite fields of city, shop, and wheels. Map function return a list of keys and values. The javascript "emit" function in this example was supplied the city as the first argument, hence city becomes the key.

An irrelevant point in case anyone is wondering what the "decks" field refers to in the full documents described above - a deck is the wooden part of the skateboard and traditionally refers to the width in inches. Skateboards have a curious mixture of imperial and metric measurements - the metal wheel mounting known as the "truck" actually has an axle diameter in mm which is slightly undersize for an imperial "608" sized bearing - it's close enough and being oversized never seizes unlike some attempts to produce more finely engineered skateboards!

We can take this map operation a step further by adding a "reduce" javascript function to our query design document. Hence making it a map-reduce operation.

The following query runs the map operation to perform the following things:
* Filter on all skateshop documents.
* Emit a list of keys and a list of values. The keys are the city and each value in the value list is itself a list of wheels.
* Run the reduce function on the list of keys (cities) and list of values (wheel size lists).

The reduce function does the following:
* Ignore the "k" key parameter - the city is not needed for the calculation.
* Iterate over the list of lists totalling the wheel diameters and counting how many wheel diameters it has itereated over.
* Returns total diameter/count which is the average wheel size offered by the shops.
 
The above map function updated with the reduce function to perform the above average wheel size calculation is:

<pre><code>
{”views”:{“get wheels”:{“map”:”function(doc) { 
    if(doc.shop && doc.wheels && doc.city) { 
        emit(doc.city, doc.wheels);}}”,
        ”reduce”:”function(k, v) { 
            var total, count; total = 0; count = 0;
            for (var idx in v) { 
                for (var idy in v[idx]) { 
                    total = total + v[idx][idy];
                }
                count = count + v[idx].length;
            };
            return (total / count); }”}}}
</code></pre>

We can POST it off to a new design (CouchDB query) document URI (assuming we want to keep the original map query), or PUT it if we want to edit the original.

Although the reduce function does not look at the keys, choosing city as the key allows us to feed in a query parameter to the map part of the operation. e.g. to run the map-reduce query with a key parameter to filter on certain keys (cities in this case) we can do a GET on the following:

<pre><code>
http://127.0.0.1:5984/hello/_design/redwheels/_view/getwheels?key="Melbourne"
</code></pre>

We will get:
<pre><code>
{“rows”:[
{“key”:null,”value”:53.5}
]}
</code></pre>

This is the average wheel size in mm for all stock carried in Melbourne.

I imagine that a distributed or parallel average could be calculated by replicating the database hello, performing a map-reduce for melbourne in on original database, a map-reduce for Sydney on the replication, then feeding the two averages into a simple script to calculate the total average for all shops in Melbourne and Sydney.
