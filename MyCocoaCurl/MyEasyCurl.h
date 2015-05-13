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

- (BOOL)InitConnection;

- (BOOL)SetGetMethod;

- (BOOL)SetPostMethod;

- (BOOL)SetPutMethod;

- (BOOL)SetDeleteMethod;

- (BOOL)SetPostData: (NSString*)data;

- (BOOL)SetJsonContent;

- (BOOL)Run: (NSString*)url;

- (NSString*)GetContent;

- (NSString*)GetError;

- (id)init;

- (void)dealloc;


@end


#endif
