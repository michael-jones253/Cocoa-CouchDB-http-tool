//
//  MyEasyController.h
//  CocoaCurl
//
//  Created by Michael Jones on 13/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef CocoaCurl_MyEasyController_h
#define CocoaCurl_MyEasyController_h
#import <Foundation/Foundation.h>
#import "MyEasyCurlTypes.h"
#import "MyEasyCurl.h"

@interface MyEasyController : NSObject

@property MyHttpMethod httpMethod;
@property NSString* postData;
@property BOOL isPlainTextAttachment;
@property BOOL isDumpOn;
@property NSData* imageData;

+ (void)setRunError:(NSError**) runError withMessage:(NSString*)message;

- (id)init;

- (BOOL)runUrl: (NSString*)url applicationData: (NSString*)data error: (NSError**)runError;

- (BOOL)pushReplicateUrl: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError;

- (BOOL)pushSyncUrl: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError;

- (BOOL)pullReplicateUrl: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError;

- (BOOL)pullSyncUrl: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError;

- (BOOL)loadImageFromFile: (NSString*) fileName imageSize: (NSUInteger*)length error: (NSError**)loadError;

- (NSString*)getResult;

- (NSString*)getDump;

// Replication stuff
- (NSArray*)getDbNamesForHost: (NSString*)host error: (NSError**)getError;

@end


#endif
