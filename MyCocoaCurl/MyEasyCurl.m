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
// using namespace std;

- (void)Greeting {
    NSLog(@"Objective Greeting %@", self.MyGreeting);
    
}

- (void)HelloCurl {
    MyCurlCpp::MyCurl* impl = (MyCurlCpp::MyCurl*)self->myImpl;
    impl->HelloCurl();
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

@end
