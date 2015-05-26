//
//  MyEasyCurl.m
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyEasyCurl.h"

// C++
#include "MyCurl.h"

@interface MyEasyCurl()
// Private.
- (void)CurlError: (NSError**)curlError;
@end

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

- (BOOL)InitConnection: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    BOOL ret = impl->InitConnection();
    
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetGetMethod: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetGetMethod();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetPostMethod: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostMethod();
    if (!ret) {
        [self CurlError: curlError];
    }

    return ret;
}

- (BOOL)SetPutMethod: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutMethod();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetDeleteMethod: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDeleteMethod();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetPostData: (NSString*)data error: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostData([ data UTF8String]);
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetPutData: (NSString*)data error: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutData([ data UTF8String]);
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetImageDataNoCache: (NSData*) data error: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const void* bytes = [data bytes];
    NSUInteger length = [data length];

    BOOL ret = impl->SetPutNoCacheData(static_cast<char const*>(bytes), length);
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetJsonContent: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJsonContent();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetPlainTextContent: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPlainTextContent();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetJpegContent: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJpegContent();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)SetDebugOn: (NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDebugOn();
    if (!ret) {
        [self CurlError: curlError];
    }
    
    return ret;
}

- (BOOL)Run: (NSString*)url error: (NSError**)curlError{
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const char* cUrl = [ url UTF8String];
    BOOL ret = impl->Run(cUrl);
    if (!ret) {
        [self CurlError: curlError];
    }
    
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

- (void)CurlError: (NSError**)curlError {
    if (curlError == nil) {
        return;
    }
    
    NSString* message = [self GetError];
    
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    *curlError = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
}

@end
