//
//  MyEasyCurl.h
//  CocoaCurl
//
//  Created by Michael Jones on 12/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef CocoaCurl_MyEasyCurl_h
#define CocoaCurl_MyEasyCurl_h
#import <Foundation/Foundation.h>
#import "MyEasyCurlTypes.h"

@interface MyEasyCurl : NSObject {
    void* myImpl;
}

@property NSString *MyGreeting;

- (void)Greeting;

- (void)HelloCurl;

- (BOOL)InitConnection: (NSError**)curlError;

- (BOOL)SetGetMethod;

- (BOOL)SetPostMethod: (NSError**)curlError;

- (BOOL)SetPutMethod;

- (BOOL)SetDeleteMethod;

- (BOOL)SetPostData: (NSString*)data error: (NSError**)curlError;

- (BOOL)SetPutData: (NSString*)data;

- (BOOL)SetImageDataNoCache: (NSData*) data;

- (BOOL)SetJsonContent: (NSError**)curlError;

- (BOOL)SetPlainTextContent;

- (BOOL)SetJpegContent;

- (BOOL)SetDebugOn;

- (BOOL)Run: (NSString*)url error: (NSError**)curlError;

- (NSString*)GetContent;

- (NSString*)GetDump;

- (NSString*)GetError;

- (id)init;

- (void)dealloc;


@end


#endif
