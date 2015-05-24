//
//  MyEasyController.m
//  
//
//  Created by Michael Jones on 13/05/2015.
//
//

#import "MyEasyController.h"

@interface MyEasyController()
// Private.
- (NSError*)MakeRunError: (NSString*const)message;

- (BOOL)ValidateSelection: (NSString*)url error: (NSError**)validationError;

- (NSData*) dataFromImageFile: (NSString*)fileName error: (NSError**)loadError;

- (BOOL)Replicate: (NSString*)localUrl
   destinationUrl: (NSString*)remoteUrl
     createTarget: (BOOL) createTarget
             push: (BOOL) push
            error: (NSError**)replicateError;

- (BOOL)SetupConnectionForJsonPost: (NSError**)connectionError;

- (BOOL)ParseDbUrl: (NSString*)url host: (NSString**)host dbName: (NSString**)dbName error: (NSError**)parseError;

- (BOOL)CheckResponseOk: (NSString*)response error: (NSError**)parseError;

@end


@implementation MyEasyController

- (id)init {
    self = [super init];
    if (self) {
        self.httpMethod = MyHttpMethodGet;
        self.postData = @"{\"company\": \"Example, Inc.\"}";
        self.isPlainTextAttachment = FALSE;
        self->_myEasyModel = [[MyEasyCurl alloc]init];
    }    
    
    return self;
}

- (BOOL)RunUrl: (NSString*)url applicationData: (NSString*)data error: (NSError**)runError {
    if (![self->_myEasyModel InitConnection: runError]) {
        return FALSE;
    }
    
    if (![self ValidateSelection:url error: runError]) {
        return FALSE;
    }
    
    
    if (self.isDumpOn) {
        if (![self->_myEasyModel SetDebugOn: runError]) {
            return FALSE;
        }
    }

    self.postData = data;
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            if (![self->_myEasyModel SetGetMethod: runError]) {
                return FALSE;
            }
            break;
            
        case MyHttpMethodPost:
            if (![self->_myEasyModel SetPostMethod: runError]) {
                return FALSE;
            }
            
            if (![self->_myEasyModel SetPostData:self.postData error:runError]) {
                return FALSE;
            }
            
            if (![self->_myEasyModel SetJsonContent: runError]) {
                return FALSE;
            }
            break;
            
        case MyHttpMethodPut:
            if (![self->_myEasyModel SetPutMethod: runError]) {
                return FALSE;
            }

            if (self->_imageData != nil) {
                if (![self->_myEasyModel SetImageDataNoCache:self.imageData error: runError]) {
                    return FALSE;
                }
                
                if (![self->_myEasyModel SetJpegContent: runError]) {
                    return FALSE;
                }
                
                // Image takes priority over plain text attachment.
                break;
            }
            
            if (![self->_myEasyModel SetPutData: self.postData error: runError]) {
                return FALSE;
            }
            
            if (self.isPlainTextAttachment) {
                if (![self->_myEasyModel SetPlainTextContent: runError]) {
                    return FALSE;
                }
            }
            else {
                if(![self->_myEasyModel SetJsonContent: runError]) {
                    return FALSE;
                }
            }
            
            break;
            
        case MyHttpMethodDelete:
            if (![self->_myEasyModel SetDeleteMethod: runError]) {
                return FALSE;
            }
            break;
            
        default:
            break;
    }

    if(![self->_myEasyModel Run:url error: runError]) {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)PushReplicate: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError {

    if (![self Replicate:localUrl destinationUrl:remoteUrl createTarget:TRUE push:TRUE error:replicateError]) {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)PullReplicate: (NSString*)localUrl destinationUrl: (NSString*)remoteUrl error: (NSError**)replicateError {
    
    if (![self Replicate:localUrl destinationUrl:remoteUrl createTarget:TRUE push:FALSE error:replicateError]) {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)LoadImageFromFile: (NSString*) fileName  imageSize: (NSUInteger*)length error: (NSError**)loadError {
    
    NSString *fullPath = [fileName stringByExpandingTildeInPath];

    self.imageData = [self dataFromImageFile:fullPath error:loadError];
    if (self.imageData != nil) {
        *length = [self.imageData length];
    }
    
    return self.imageData != nil;
}


- (NSString*)GetResult {
    return [self->_myEasyModel GetContent];
}

- (NSString*)GetDump {
    return [self->_myEasyModel GetDump];
}

- (BOOL)Replicate: (NSString*)localUrl
   destinationUrl: (NSString*)remoteUrl
     createTarget: (BOOL) createTarget
             push: (BOOL) push
            error: (NSError**)replicateError {
    if (![self SetupConnectionForJsonPost:replicateError]) {
        return FALSE;
    }
    
    // Get the name of the database which is the identifier after the last '/'.
    NSString* localDb = nil;
    NSString* localHost = nil;
    
    if (![self ParseDbUrl:localUrl host:&localHost dbName:&localDb error:replicateError]) {
        return FALSE;
    }
    
    NSString* source = push ? localDb : remoteUrl;
    NSString* destination = push ? remoteUrl : localDb;
    
    /*
     We want something like this:
     curl -vX POST http://127.0.0.1:5984/_replicate -d '{"source":"albums","target":"example.com:5984/albums-replica"}' -H "Content-Type: application/json"
     */
    NSString* createInstruction = createTarget? @", \"create_target\":true" : @"";
    NSString* postString = [NSString stringWithFormat:@"{\"source\":\"%@\", \"target\":\"%@\"%@}",
                            source, destination, createInstruction];
    
    NSString* replicateUrl = [localHost stringByAppendingString:@"_replicate"];
    NSLog(@"Replicate: %@ postData: %@", replicateUrl, postString);
    
    if (![self->_myEasyModel SetPostData:postString error:replicateError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel Run:replicateUrl error:replicateError]) {
        return FALSE;
    }
    
    NSString* response = [self->_myEasyModel GetContent];
    
    if (![self CheckResponseOk:response error:replicateError]) {
        return FALSE;
    }
    return TRUE;
}

- (NSArray*)GetDbNamesForHost: (NSString*)host error: (NSError**)getError {
    
    NSString* getRequest = [NSString stringWithFormat:@"http://%@:5984/_all_dbs", host];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:getRequest]];
    
    
    NSURLResponse* httpResponse;
    NSData *allDbsData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&httpResponse error:getError];
    
    if (httpResponse == nil) {
        if (getError != nil && *getError == nil) {
            *getError = [self MakeRunError:@"empty http response"];
        }
        
        return nil;
    }
    
    NSArray* httpResponseInformation = [httpResponse attributeKeys];
    // FIX ME - parse the above response.
    
    NSArray *databaseNames = [NSJSONSerialization JSONObjectWithData:allDbsData
                                                             options:0 error:getError];
    
    return databaseNames;
}


- (NSError*)MakeRunError: (NSString*const)message {
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    NSError *error = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
    return error;
}

- (BOOL)ValidateSelection: (NSString*)url error: (NSError**)validationError {
    if (self.isPlainTextAttachment && self.httpMethod != MyHttpMethodPut) {
        if (validationError != nil) {
            *validationError = [self MakeRunError:@"Plain text attachment must use PUT"];
        }
        return FALSE;
    }
    
    if (self.httpMethod != MyHttpMethodPut) {
        self.imageData = nil;
    }
    
    if (self.isPlainTextAttachment && ![url containsString:@"attachment"]) {
        if (validationError != nil) {
            *validationError = [self MakeRunError:@"Plain text attachment must have \"attachment?rev=<revision>\" in URI"];
        }
        return FALSE;
    }
    
    if ((self.isPlainTextAttachment || self->_imageData != nil) && ![url containsString:@"?rev="]) {
        if (validationError != nil) {
            *validationError = [self MakeRunError:@"Attachment must specify document revision: ?rev=<revision>"];
        }
        return FALSE;
    }
    
    if (self->_imageData != nil && ![url containsString:@".jpg"]) {
        if (validationError != nil) {
            *validationError = [self MakeRunError:@"Image attachment must specify image in URI"];
        }
        return FALSE;
    }
    
    return TRUE;
}

- (NSData*) dataFromImageFile: (NSString*)fileName error: (NSError**)loadError{
    NSData* imageData = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedAlways error:loadError];
    return imageData;
}

- (BOOL)SetupConnectionForJsonPost: (NSError**)connectionError {
    if (![self->_myEasyModel InitConnection: connectionError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel SetPostMethod: connectionError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel SetJsonContent: connectionError]) {
        return FALSE;
    }

    return TRUE;
}

- (BOOL)CheckResponseOk: (NSString*)response error: (NSError**)parseError {
    
    NSData* responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
    
    NSObject* parsedJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:parseError];
    
    if (![parsedJson isKindOfClass:[NSDictionary class]]) {
        *parseError = [self MakeRunError:@"Response not a json dictionary"];
        return FALSE;
    }
    
    NSDictionary *responseKeyValues = (NSDictionary*)parsedJson;
    if ([responseKeyValues objectForKey:@"error"] != nil) {
        *parseError = [self MakeRunError:[responseKeyValues objectForKey:@"error"]];
        return FALSE;
    }
    
    return TRUE;

}

- (BOOL)ParseDbUrl: (NSString*)url host: (NSString**)host dbName: (NSString**)dbName error: (NSError**)parseError {
    
    // Get the name of the database which is the identifier after the last '/'.
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, [url length])];
    NSUInteger dbIndex = range.location + 1;
    
    *host = [url substringToIndex:dbIndex];
    if (*host == nil) {
        *parseError = [self MakeRunError:@"Unable to parse host from URL"];
        return FALSE;
    }
    
    *dbName = [url substringFromIndex:dbIndex];
    if (*dbName == nil) {
        *parseError = [self MakeRunError:@"Unable to parse database name from URL"];
        return FALSE;
    }

    return TRUE;
}

@end
