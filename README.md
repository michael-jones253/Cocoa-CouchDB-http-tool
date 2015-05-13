# Cocoa-CouchDB-http-tool
An OS X Cocoa app for playing with the NoSQL CouchDB via the http API.

## Motivation for this project.
Although I am mainly a back end server/distributed systems programmer I frequently have to maintain GUIs so I thought I would get to know the OS X Cocoa interface and make a foray into some Objective-C. This app allows me to play with CouchDB via the http API which is also something I am interested in.

## Structure of this project.
I am attempting to follow the MVC pattern in the following way:

1. A c++ dylib which takes the role of the 'model'. This dynamic library uses 'libcurl' to formulate the http requests.
2. An Objective-C framework which calls the above dylib and acts as the 'controller'.
3. The Xcode generated Document.h/m acts as the view.

## Initial impressions and grappling with Objective-C.
Objective-C can be mixed with C++ so this allowed me to call the dylib from the Objective-C framework using a similar technique to a Dr Dobbs tutorial.

I had previously learned to use Apple's Swift language and my reaction was Swift does not have exceptions?! However, it seems that Objective-C exceptions aren't quite like what I was hoping for as a C++ programmer. I consider exception driven C++ to be the superior control flow compared to error code returns. The reason is that I have seen frequent programming mistakes where the developer has ignored the error code and the code carries on regardless of whether an error has occurred or not. It also leads to ambiguous API situations where the developer is not sure whether the code can be ignored or not. Exceptions in comparison are unequivocal. Another error that occurs is that the return code value e.g. integer is wrongly interpreted e.g. treated as a bool when -1 is intended to indicate an error.

What I am reading about Objective-C exceptions is that they are only intended for programmer errors and are otherwisediscouraged. At the time of writing this README this app is work in progress and I need to sort out the use of errors Vs exceptions in my Cocoa framework. NSError should replae bool and I currently have an inconsistent mixture of situations where a method may return an error code - sometimes it would be from a programming error e.g. forgot to initialise the CURL connection before setting a HTTP option and sometimes it would be from every day error situations such as the server is down or the URL is wrong. 
