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

- (BOOL)ParseDbUrl: (NSString*)url host: (NSString**)host dbName: (NSString**)dbName error: (NSError**)parseError;

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
    if (![self->_myEasyModel InitConnection: replicateError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel SetPostMethod: replicateError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel SetJsonContent: replicateError]) {
        return FALSE;
    }
    
    // Get the name of the database which is the identifier after the last '/'.
    NSString* localDb = nil;
    NSString* localHost = nil;
    
    if (![self ParseDbUrl:localUrl host:&localHost dbName:&localDb error:replicateError]) {
        return FALSE;
    }
    
    /*
     We want something like this:
     curl -vX POST http://127.0.0.1:5984/_replicate -d '{"source":"albums","target":"albums-replica"}' -H "Content-Type: application/json"
     */

    NSString* postString = [NSString stringWithFormat:@"{\"source\":\"%@\", \"target\":\"%@\"}", localDb, remoteUrl];
    
    NSString* replicateUrl = [localHost stringByAppendingString:@"_replicate"];
    NSLog(@"Replicate: %@ postData: %@", replicateUrl, postString);
    
    if (![self->_myEasyModel SetPostData:postString error:replicateError]) {
        return FALSE;
    }
    
    if (![self->_myEasyModel Run:replicateUrl error:replicateError]) {
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
