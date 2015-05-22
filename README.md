# Cocoa-CouchDB-http-tool
An OS X Cocoa app for playing with the NoSQL CouchDB via the http API.

## Motivation for this project.
Although I am mainly a back end server/distributed systems programmer I frequently have to maintain GUIs so I thought I would get to know the OS X Cocoa interface and make a foray into some Objective-C. This app allows me to play with CouchDB via the http API which is also something I am interested in. This is my first go at Objective-C and I probably am not doing everything using best practises. e.g Since starting I realised that class extensions i.e. declaring a @interface <class name>() at the top of the .m file is the approved way of declaring private methods. It might be the best place for keeping private "attributes" too in the form of properties - I started out by enclosing the private stuff within "{}" braces on the interface in the .h file.

## Structure of this project.
I am attempting to follow the MVC pattern in the following way:

1. A c++ dylib which takes the role of the 'model'. This dynamic library uses 'libcurl' to formulate the http requests.
2. An Objective-C framework which calls the above dylib and acts as the 'controller'.
3. The Xcode generated Document.h/m acts as the view.

The idea is that the dylib model could be used by any application GUI or otherwise. The Controller is the what sits in between this model and the GUI view. The controller is responsible for making sure that user initiated actions and selections from the view are sent to the model in an orderly way e.g. connection initiated before setting HTTP parameters to libcurl. The controller does some parameter validation and provides any error and result feedback to the view.

I also tried to design it such that changes to the view should not require major changes to the controller.

## Initial impressions and grappling with Objective-C.
Once I got over the square brackets method call syntax I decided that this language is not so alien. Objective-C can be mixed with C++ so this allowed me to call the dylib from the Objective-C framework using a similar technique to a Dr Dobbs tutorial.

I had previously learned Apple's Swift language and my reaction was Swift does not have exceptions?! However, it seems that Objective-C exceptions aren't quite like what I was hoping for as a C++ programmer. I consider exception driven C++ to be the superior control flow compared to error code returns. The reason is that I have seen frequent programming mistakes where the developer has ignored the error code and the code carries on regardless of whether an error has occurred or not. It also leads to ambiguous API situations where the developer is not sure whether the code can be ignored or not. Exceptions in comparison are unequivocal. Another error that occurs is that the return code value e.g. integer is wrongly interpreted e.g. treated as a bool when -1 is intended to indicate an error.

What I am reading about Objective-C exceptions is that they are only intended for programmer errors and are otherwise discouraged. At the time of writing this README this app is work in progress and I need to sort out the use of errors Vs exceptions in my Cocoa framework. NSError should replae bool and I currently have an inconsistent mixture of situations where a method may return an error code - sometimes it would be from a programming error e.g. forgot to initialise the CURL connection before setting a HTTP option and sometimes it would be from every day error situations such as the server is down or the URL is wrong.

An update to my thoughts on the above exception discussion is that I still think exception based code (as opposed to error return code) is the superior form of control flow and should be used for C++, however it is best not to fight the Objective-C NSError return methodology. Many of the "Foundation" classes provided by Apple take the approach of returnign NSError objects via parameters, so passing these up the call chain is more straightforward than converting them to exceptions in an attempt to produce exception driven control flow.
