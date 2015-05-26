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
@property MyEasyCurl* myEasyModel;


- (BOOL)ValidateSelection:(NSString*)url error:(NSError**)validationError;

- (NSData*) dataFromImageFile:(NSString*)fileName error:(NSError**)loadError;

- (BOOL)Replicate:(NSString*)localUrl
   destinationUrl:(NSString*)remoteUrl
     createTarget:(BOOL) createTarget
             push:(BOOL) push
            error:(NSError**)replicateError;

- (BOOL)SetupConnectionForJsonPost:(NSError**)connectionError;

- (BOOL)parseDbUrl:(NSString*)url toHostUrl:(NSString**)host toDbName:(NSString**)dbName error:(NSError**)parseError;

- (BOOL)validateReplicateForRemoteHostUrl:(NSString*) remoteHostUrl
                           localDbName:(NSString*) localDbName
                          remoteDbName:(NSString*)remoteDbName
                                 error:(NSError**) error;


- (BOOL)CheckResponseOk:(NSString*)response error:(NSError**)parseError;

@end


@implementation MyEasyController

- (id)init {
    self = [super init];
    if (self) {
        self.httpMethod = MyHttpMethodGet;
        self.postData = @"{\"company\": \"Example, Inc.\"}";
        self.isPlainTextAttachment = NO;
        self.myEasyModel = [[MyEasyCurl alloc]init];
    }    
    
    return self;
}

- (BOOL)runUrl:(NSString*)url applicationData:(NSString*)data error:(NSError**)runError {
    if (![self.myEasyModel InitConnection: runError]) {
        return NO;
    }
    
    if (![self ValidateSelection:url error: runError]) {
        return NO;
    }
    
    
    if (self.isDumpOn) {
        if (![self.myEasyModel SetDebugOn: runError]) {
            return NO;
        }
    }

    self.postData = data;
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            if (![self.myEasyModel SetGetMethod: runError]) {
                return NO;
            }
            break;
            
        case MyHttpMethodPost:
            if (![self.myEasyModel SetPostMethod: runError]) {
                return NO;
            }
            
            if (![self.myEasyModel SetPostData:self.postData error:runError]) {
                return NO;
            }
            
            if (![self.myEasyModel SetJsonContent: runError]) {
                return NO;
            }
            break;
            
        case MyHttpMethodPut:
            if (![self.myEasyModel SetPutMethod: runError]) {
                return NO;
            }

            if (self->_imageData != nil) {
                if (![self.myEasyModel SetImageDataNoCache:self.imageData error: runError]) {
                    return NO;
                }
                
                if (![self.myEasyModel SetJpegContent: runError]) {
                    return NO;
                }
                
                // Image takes priority over plain text attachment.
                break;
            }
            
            if (![self.myEasyModel SetPutData: self.postData error: runError]) {
                return NO;
            }
            
            if (self.isPlainTextAttachment) {
                if (![self.myEasyModel SetPlainTextContent: runError]) {
                    return NO;
                }
            }
            else {
                if(![self.myEasyModel SetJsonContent: runError]) {
                    return NO;
                }
            }
            
            break;
            
        case MyHttpMethodDelete:
            if (![self.myEasyModel SetDeleteMethod: runError]) {
                return NO;
            }
            break;
            
        default:
            break;
    }

    if(![self.myEasyModel Run:url error: runError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pushReplicateUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {

    if (![self Replicate:localUrl destinationUrl:remoteUrl createTarget:YES push:YES error:replicateError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pullReplicateUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {
    
    if (![self Replicate:localUrl destinationUrl:remoteUrl createTarget:YES push:NO error:replicateError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)loadImageFromFile:(NSString*) fileName  imageSize:(NSUInteger*)length error:(NSError**)loadError {
    
    NSString *fullPath = [fileName stringByExpandingTildeInPath];

    self.imageData = [self dataFromImageFile:fullPath error:loadError];
    if (self.imageData != nil) {
        *length = [self.imageData length];
    }
    
    return self.imageData != nil;
}


- (NSString*)getResult {
    return [self.myEasyModel GetContent];
}

- (NSString*)getDump {
    return [self.myEasyModel GetDump];
}

- (BOOL)Replicate:(NSString*)localUrl
   destinationUrl:(NSString*)remoteUrl
     createTarget:(BOOL) createTarget
             push:(BOOL) push
            error:(NSError**)replicateError {
    if (![self SetupConnectionForJsonPost:replicateError]) {
        return NO;
    }
    
    // Get the name of the database which is the identifier after the last '/'.
    NSString* localDbName;
    NSString* localHostUrl;
    
    if (![self parseDbUrl:localUrl toHostUrl:&localHostUrl toDbName:&localDbName error:replicateError]) {
        return NO;
    }
    
    NSString* remoteDbName;
    NSString* remoteHostUrl;
    if (![self parseDbUrl:remoteUrl toHostUrl:&remoteHostUrl toDbName:&remoteDbName error:replicateError]) {
        return NO;
    }
    
    NSString* source = push ? localDbName : remoteUrl;
    NSString* destination = push ? remoteUrl : localDbName;
    
    if (![self validateReplicateForRemoteHostUrl:remoteHostUrl localDbName:localDbName remoteDbName:remoteDbName error:replicateError]) {
        return NO;
    }
    
    /*
     We want something like this:
     curl -vX POST http://127.0.0.1:5984/_replicate -d '{"source":"albums","target":"example.com:5984/albums-replica"}' -H "Content-Type: application/json"
     */
    NSString* createInstruction = createTarget? @", \"create_target\":true" : @"";
    NSString* postString = [NSString stringWithFormat:@"{\"source\":\"%@\", \"target\":\"%@\"%@}",
                            source, destination, createInstruction];
    
    NSString* replicateUrl = [localHostUrl stringByAppendingString:@"_replicate"];
    NSLog(@"Replicate: %@ postData: %@", replicateUrl, postString);
    
    if (![self.myEasyModel SetPostData:postString error:replicateError]) {
        return NO;
    }
    
    if (![self.myEasyModel Run:replicateUrl error:replicateError]) {
        return NO;
    }
    
    NSString* response = [self.myEasyModel GetContent];
    
    if (![self CheckResponseOk:response error:replicateError]) {
        return NO;
    }
    return YES;
}

- (NSArray*)getDbNamesForHost:(NSString*)host error:(NSError**)getError {
    
    NSString* getRequest = [NSString stringWithFormat:@"http://%@:5984/_all_dbs", host];
    
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getRequest]];
    NSTimeInterval timeout = 5;
    [urlRequest setTimeoutInterval:timeout];
    
    //NSURLResponse* httpResponse;
    NSHTTPURLResponse* httpResponse;
    NSData *allDbsData = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&httpResponse error:getError];
    
    if (httpResponse == nil) {
        if (getError != nil && *getError == nil) {
            [MyEasyController setRunError:getError withMessage:@"No http response"];
        }
        
        return nil;
    }
    
    if (allDbsData == nil) {
        if (getError != nil && *getError == nil) {
            [MyEasyController setRunError:getError withMessage:@"Empty http response"];
        }
        
        return nil;
    }
    
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode != 200) {
        NSString* unexpectedStatus = [NSHTTPURLResponse localizedStringForStatusCode: statusCode];
        [MyEasyController setRunError:getError withMessage:unexpectedStatus];
        return nil;
    }    
    
    NSArray *databaseNames = [NSJSONSerialization JSONObjectWithData:allDbsData
                                                             options:0 error:getError];
    
    return databaseNames;
}

- (BOOL)validateReplicateForRemoteHostUrl:(NSString*) remoteHostUrl
                           localDbName:(NSString*) localDbName
                          remoteDbName:(NSString*)remoteDbName
                                 error:(NSError**) error {
    BOOL sourceDestEqual = [localDbName isEqualToString:remoteDbName];
    
    // FIX ME Need to test for ip resolving to this machine too.
    BOOL destIsLocalHost = [remoteHostUrl containsString:@"127.0.0.1"] || [remoteHostUrl containsString:@"localhost"];
    
    if (sourceDestEqual && destIsLocalHost) {
        [MyEasyController setRunError:error withMessage:@"Source DB must be different from destination DB"];
        return NO;
    }
    
    // Now check that selected database name doesn't begin with '_'.
    BOOL localSystemDbSelected = [localDbName hasPrefix:@"_"];
    BOOL remoteSystemDbSelected = [remoteDbName hasPrefix:@"_"];
    if (localSystemDbSelected || remoteSystemDbSelected) {
        [MyEasyController setRunError:error withMessage:@"Cannot replicate system databases"];
        return NO;
    }
    
    if ([localDbName isEqualToString:@""]) {
        [MyEasyController setRunError:error withMessage:@"Local DB must be specified"];
        return NO;
    }
    
    if ([remoteDbName isEqualToString:@""]) {
        [MyEasyController setRunError:error withMessage:@"Remote DB must be specified"];
        return NO;
    }

    return YES;
}


+ (void)setRunError:(NSError**) runError withMessage:(NSString*)message {
    if (runError == nil) {
        return;
    }
    
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    *runError = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
}

- (BOOL)ValidateSelection:(NSString*)url error:(NSError**)validationError {
    if (self.isPlainTextAttachment && self.httpMethod != MyHttpMethodPut) {
        [MyEasyController setRunError:validationError withMessage:@"Plain text attachment must use PUT"];
        return NO;
    }
    
    if (self.httpMethod != MyHttpMethodPut) {
        self.imageData = nil;
    }
    
    if (self.isPlainTextAttachment && ![url containsString:@"attachment"]) {
        [MyEasyController setRunError:validationError withMessage:@"Plain text attachment must have \"attachment?rev=<revision>\" in URI"];
        return NO;
    }
    
    if ((self.isPlainTextAttachment || self->_imageData != nil) && ![url containsString:@"?rev="]) {
        [MyEasyController setRunError:validationError withMessage:@"Attachment must specify document revision: ?rev=<revision>"];
        return NO;
    }
    
    if (self->_imageData != nil && ![url containsString:@".jpg"]) {
        [MyEasyController setRunError:validationError withMessage:@"Image attachment must specify image in URI"];
        return NO;
    }
    
    return YES;
}

- (NSData*) dataFromImageFile:(NSString*)fileName error:(NSError**)loadError{
    NSData* imageData = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMappedAlways error:loadError];
    return imageData;
}

- (BOOL)SetupConnectionForJsonPost:(NSError**)connectionError {
    if (![self.myEasyModel InitConnection: connectionError]) {
        return NO;
    }
    
    if (![self.myEasyModel SetPostMethod: connectionError]) {
        return NO;
    }
    
    if (![self.myEasyModel SetJsonContent: connectionError]) {
        return NO;
    }

    return YES;
}

- (BOOL)CheckResponseOk:(NSString*)response error:(NSError**)parseError {
    
    NSData* responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
    
    NSObject* parsedJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:parseError];
    
    if (![parsedJson isKindOfClass:[NSDictionary class]]) {
        [MyEasyController setRunError:parseError withMessage:@"Response not a json dictionary"];
        return NO;
    }
    
    NSDictionary *responseKeyValues = (NSDictionary*)parsedJson;
    if ([responseKeyValues objectForKey:@"error"] != nil) {
        [MyEasyController setRunError:parseError withMessage:[responseKeyValues objectForKey:@"error"]];
        return NO;
    }
    
    return YES;

}

- (BOOL)parseDbUrl:(NSString*)url toHostUrl:(NSString**)host toDbName:(NSString**)dbName error:(NSError**)parseError {
    
    // Get the name of the database which is the identifier after the last '/'.
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, [url length])];
    NSUInteger dbIndex = range.location + 1;
    
    *host = [url substringToIndex:dbIndex];
    if (*host == nil) {
        [MyEasyController setRunError:parseError withMessage:@"Unable to parse host from URL"];
        return NO;
    }
    
    *dbName = [url substringFromIndex:dbIndex];
    if (*dbName == nil) {
        [MyEasyController setRunError:parseError withMessage:@"Unable to parse database name from URL"];
        return NO;
    }

    return YES;
}

@end
