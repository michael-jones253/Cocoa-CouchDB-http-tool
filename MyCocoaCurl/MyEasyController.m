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


- (BOOL)validateSelection:(NSString*)url error:(NSError**)validationError;

- (NSData*) dataFromImageFile:(NSString*)fileName error:(NSError**)loadError;

- (BOOL)replicate:(NSString*)localUrl
   destinationUrl:(NSString*)remoteUrl
     createTarget:(BOOL) createTarget
             push:(BOOL) push
            error:(NSError**)replicateError;

- (BOOL)setupConnectionForJsonPost:(NSError**)connectionError;

- (BOOL)parseDbUrl:(NSString*)url toHostUrl:(NSString**)host toDbName:(NSString**)dbName error:(NSError**)parseError;

- (BOOL)validateReplicateForRemoteHostUrl:(NSString*) remoteHostUrl
                           localDbName:(NSString*) localDbName
                          remoteDbName:(NSString*)remoteDbName
                                 error:(NSError**) error;


- (BOOL)checkResponseOk:(NSString*)response error:(NSError**)parseError;

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
    if (![self.myEasyModel initConnection:runError]) {
        return NO;
    }
    
    if (![self validateSelection:url error:runError]) {
        return NO;
    }
    
    
    if (self.isDumpOn) {
        if (![self.myEasyModel setDebugOn:runError]) {
            return NO;
        }
    }

    self.postData = data;
    
    switch (self.httpMethod) {
        case MyHttpMethodGet:
            if (![self.myEasyModel setGetMethod:runError]) {
                return NO;
            }
            break;
            
        case MyHttpMethodPost:
            if (![self.myEasyModel setPostMethod:runError]) {
                return NO;
            }
            
            if (![self.myEasyModel setPostData:self.postData error:runError]) {
                return NO;
            }
            
            if (![self.myEasyModel setJsonContent:runError]) {
                return NO;
            }
            break;
            
        case MyHttpMethodPut:
            if (![self.myEasyModel setPutMethod:runError]) {
                return NO;
            }

            if (self->_imageData != nil) {
                if (![self.myEasyModel setImageDataNoCache:self.imageData error:runError]) {
                    return NO;
                }
                
                if (![self.myEasyModel setJpegContent:runError]) {
                    return NO;
                }
                
                // Image takes priority over plain text attachment.
                break;
            }
            
            if (![self.myEasyModel setPutData: self.postData error:runError]) {
                return NO;
            }
            
            if (self.isPlainTextAttachment) {
                if (![self.myEasyModel setPlainTextContent:runError]) {
                    return NO;
                }
            }
            else {
                if(![self.myEasyModel setJsonContent:runError]) {
                    return NO;
                }
            }
            
            break;
            
        case MyHttpMethodDelete:
            if (![self.myEasyModel setDeleteMethod:runError]) {
                return NO;
            }
            break;
            
        default:
            break;
    }

    if(![self.myEasyModel runUrl:url error:runError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pushReplicateUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {

    if (![self replicate:localUrl destinationUrl:remoteUrl createTarget:YES push:YES error:replicateError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pushSyncUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {
    if (![self replicate:localUrl destinationUrl:remoteUrl createTarget:NO push:YES error:replicateError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pullReplicateUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {
    
    if (![self replicate:localUrl destinationUrl:remoteUrl createTarget:YES push:NO error:replicateError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pullSyncUrl:(NSString*)localUrl destinationUrl:(NSString*)remoteUrl error:(NSError**)replicateError {
    if (![self replicate:localUrl destinationUrl:remoteUrl createTarget:NO push:NO error:replicateError]) {
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
    return [self.myEasyModel getContent];
}

- (NSString*)getDump {
    return [self.myEasyModel getDump];
}

- (BOOL)replicate:(NSString*)localUrl
   destinationUrl:(NSString*)remoteUrl
     createTarget:(BOOL) createTarget
             push:(BOOL) push
            error:(NSError**)replicateError {
    if (![self setupConnectionForJsonPost:replicateError]) {
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
    NSLog(@"replicate: %@ postData: %@", replicateUrl, postString);
    
    if (![self.myEasyModel setPostData:postString error:replicateError]) {
        return NO;
    }
    
    if (![self.myEasyModel runUrl:replicateUrl error:replicateError]) {
        return NO;
    }
    
    NSString* response = [self.myEasyModel getContent];
    
    if (![self checkResponseOk:response error:replicateError]) {
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
        NSString* unexpectedStatus = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
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

- (BOOL)validateSelection:(NSString*)url error:(NSError**)validationError {
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

- (BOOL)setupConnectionForJsonPost:(NSError**)connectionError {
    if (![self.myEasyModel initConnection: connectionError]) {
        return NO;
    }
    
    if (![self.myEasyModel setPostMethod: connectionError]) {
        return NO;
    }
    
    if (![self.myEasyModel setJsonContent: connectionError]) {
        return NO;
    }

    return YES;
}

- (BOOL)checkResponseOk:(NSString*)response error:(NSError**)parseError {
    
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

- (BOOL)parseDbUrl:(NSString*)url toHostUrl:(NSString**)hostUrl toDbName:(NSString**)dbName error:(NSError**)parseError {
    
    // Get the name of the database which is the identifier after the last '/'.
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, [url length])];
    NSUInteger dbIndex = range.location + 1;
    
    *hostUrl = [url substringToIndex:dbIndex];
    if (*hostUrl == nil || [*hostUrl isEqualToString:@""]) {
        [MyEasyController setRunError:parseError withMessage:@"Unable to parse host from URL"];
        return NO;
    }
    
    *dbName = [url substringFromIndex:dbIndex];
    if (*dbName == nil || [*dbName isEqualToString:@""]) {
        [MyEasyController setRunError:parseError withMessage:@"Unable to parse database name from URL"];
        return NO;
    }

    return YES;
}

@end
