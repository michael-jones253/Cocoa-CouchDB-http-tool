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
- (void)curlError:(NSError**)curlError;
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

- (void)greeting {
    NSLog(@"Objective Greeting %@", self.MyGreeting);
    
}

- (void)helloCurl {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    impl->HelloCurl();
}

- (BOOL)initConnection:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    BOOL ret = impl->InitConnection();
    
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setGetMethod:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetGetMethod();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setPostMethod:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostMethod();
    if (!ret) {
        [self curlError:curlError];
    }

    return ret;
}

- (BOOL)setPutMethod:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutMethod();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setDeleteMethod:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDeleteMethod();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setPostData:(NSString*)data error:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPostData([ data UTF8String]);
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setPutData:(NSString*)data error:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPutData([ data UTF8String]);
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setImageDataNoCache:(NSData*) data error:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const void* bytes = [data bytes];
    NSUInteger length = [data length];

    BOOL ret = impl->SetPutNoCacheData(static_cast<char const*>(bytes), length);
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setJsonContent:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJsonContent();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setPlainTextContent:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetPlainTextContent();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setJpegContent:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetJpegContent();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)setDebugOn:(NSError**)curlError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    BOOL ret = impl->SetDebugOn();
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (BOOL)runUrl:(NSString*)url error:(NSError**)curlError{
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    
    const char* cUrl = [ url UTF8String];
    BOOL ret = impl->Run(cUrl);
    if (!ret) {
        [self curlError:curlError];
    }
    
    return ret;
}

- (NSString*)getContent {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;

    std::string curlStr = impl->GetContent();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
}

- (NSString*)getDump {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;
    
    std::string const& curlStr = impl->GetDump();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
}

- (NSString*)getError {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    NSString* ret = nil;
    
    std::string curlStr = impl->GetError();
    ret = [ [NSString alloc] initWithCString:curlStr.c_str() encoding:(NSUTF8StringEncoding)];
    
    return ret;
    
}

- (void)curlError:(NSError**)curlError {
    if (curlError == nil) {
        return;
    }
    
    NSString* message = [self getError];
    
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    *curlError = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
}

@end
