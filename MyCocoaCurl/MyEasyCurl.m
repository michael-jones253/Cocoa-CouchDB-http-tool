//
//  MyEasyCurl.m
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyEasyCurl.h"
#import "MyCurl.h"

@implementation MyEasyCurl

@synthesize MyGreeting = myGreeting;

- (id)init {
    self = [super init];
    if (self) {
        myGreeting = @"synthesised greeting";
    }
    
    self->myImpl = new MyCurlCpp::MyCurl();
    
    return self;
}

- (void)dealloc {
    delete (MyCurlCpp::MyCurl*)self->myImpl;
}

- (void)Greeting {
    NSLog(@"Objective Greeting %@", self.MyGreeting);
    
}

- (void)HelloCurl {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    impl->HelloCurl();
}

- (BOOL)InitConnection {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    BOOL ret = impl->InitConnection();
    
    return ret;
}

- (BOOL)SetGetMethod {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetGetMethod();
    
    return ret;
}

- (BOOL)SetPostMethod {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostMethod();

    return ret;
}

- (BOOL)SetPutMethod {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutMethod();
    
    return ret;
}

- (BOOL)SetDeleteMethod {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDeleteMethod();
    
    return ret;
}

- (BOOL)SetPostData: (NSString*)data {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostData([ data UTF8String]);
    
    return ret;
}

- (BOOL)SetPutData: (NSString*)data {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutData([ data UTF8String]);
    
    return ret;
}

- (BOOL)SetImageDataNoCache: (NSData*) data {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const void* bytes = [data bytes];
    NSUInteger length = [data length];

    BOOL ret = impl->SetPutNoCacheData(static_cast<char const*>(bytes), length);
    
    return ret;
}

- (BOOL)SetJsonContent {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJsonContent();
    
    return ret;
}

- (BOOL)SetPlainTextContent {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPlainTextContent();
    
    return ret;
}

- (BOOL)SetJpegContent {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJpegContent();
    
    return ret;
}

- (BOOL)SetDebugOn {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDebugOn();
    
    return ret;
}

- (BOOL)Run: (NSString*)url {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const char* cUrl = [ url UTF8String];
    BOOL ret = impl->Run(cUrl);
    
    return ret;
}

- (NSString*)GetContent {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;

    std::string curlStr = impl->GetContent();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
}

- (NSString*)GetDump {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;
    
    std::string const& curlStr = impl->GetDump();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
}

- (NSString*)GetError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;
    
    std::string curlStr = impl->GetError();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
    
}

@end
