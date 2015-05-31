//
//  Document.m
//  CocoaCurl
//
//  Created by Michael Jones on 9/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import "Document.h"
#import "ReplicateWindow.h"

@interface Document ()

@property NSString* resultBuf;

@property MyEasyController* easyController;

@property NSWindowController* replicateWindowController;

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.easyController = [[MyEasyController alloc]init];
    }
    return self;
}

- (IBAction)curlButtonTapped:(id) sender {
    self.easyController.isPlainTextAttachment = ([self.attachAsPlainText state] == NSOnState) ? YES:NO;
    self.easyController.isDumpOn = ([self.dump state] == NSOnState) ? YES:NO;
    
    [self.content setString:@""];
    
    NSString *name = [sender stringValue];
    if (![name isEqualToString:@""]) {
        NSLog(@"Performing curl: %@", self.url.title);

        NSError* runError = nil;
        BOOL ok = [self.easyController runUrl:self.url.title applicationData:self.applicationData.title error:&runError];
        
        if (!ok) {
            NSString *err = (runError != nil)? runError.localizedDescription : @"Unknown run error";
            [self.content insertText:err];
            return;
        }
        
        NSString* result = [self.easyController getResult];
        
        // For some reason the text stored in the scrollview contains strange characters which looks fine to read,
        // but is invalid json if copied into the document window for a POST/PUT.
        // So we store the result in another buffer for the purpose of copying to a new query (using copy button).
        self.resultBuf = result;
        [self.content insertText:result];
        if ([self.dump state] == NSOnState) {
            [self.content insertText:@"\n"];
            [self.content insertText:[self.easyController getDump]];
            NSLog(@"DUMP: %@", [self.easyController getDump]);
        }
    }
}

- (IBAction)loadImageButtonTapped:(id) sender {
    if ([self.imagePath hasSuffix:@"jpg"]) {
        NSError* loadError = nil;
        
        NSUInteger imageLength = 0;
        BOOL loadedOk = [self.easyController loadImageFromFile:self.imagePath imageSize:&imageLength error:&loadError];
        if (!loadedOk) {
            NSString *err = (loadError != nil)? loadError.localizedDescription : @"Unknown run error";
            [self.content insertText:err];
            return;
        }
        
        NSString* msg = [NSString stringWithFormat:@"Loaded %@ %lU bytes", self.imagePath, (unsigned long)imageLength];
        [self.content insertText:msg];
        [self.content insertText:@"\nTo attach PUT <document URI>/<image name>.jpg?rev=<revision>"];
    }

}

- (IBAction)copyButtonPressed:(id)sender {
    // We copy from the result buf, because the scroll view contains characters which invalidate json.
    self.applicationData.placeholderString = self.resultBuf;
    NSInteger selectedRow = [self.httpVerb selectedRow];
    NSButtonCell *buttonCell = [[self.httpVerb cells] objectAtIndex:selectedRow];
    if ([[buttonCell title] isEqualToString:@"POST"] || [[buttonCell title] isEqualToString:@"PUT"]) {
        self.applicationData.title = self.applicationData.placeholderString;
    }
}

- (IBAction)clearButtonPressed:(id)sender {
    self.applicationData.placeholderString = @"";
    self.applicationData.title = @"";
}

- (IBAction)exampleViewButtonPressed:(id)sender {
    NSString* urlAddOn = @"/_design/mydesign";
    self.url.title = [self.url.title stringByAppendingString:urlAddOn];
    
    NSString* viewFormat = @"{\"views\":{\"company\":{\"map\":\"%@\"}}}";
    NSString* mapFunction = @"function(doc) { if(doc.company) { emit(doc.company, doc);}}";
    NSString* exampleView = [NSString stringWithFormat:viewFormat, mapFunction];
    
    self.applicationData.placeholderString = exampleView;
}

- (IBAction)httpMethodButtonSelected:(id) sender {
    NSMatrix *myMatrix = sender;
    NSString *name = [sender stringValue];
    NSString *httpMatrixName = [self.httpVerb stringValue];
    
    if ([name isEqualToString:httpMatrixName]) {
        NSInteger selectedRow = [myMatrix selectedRow];
        NSButtonCell *buttonCell = [[self.httpVerb cells] objectAtIndex:selectedRow];
        if ([[buttonCell title] isEqualToString:@"GET"]) {
            // Application data is not applicable to GET, so we save what's there in the
            // placeholder and blank it out.
            self.applicationData.placeholderString = self.applicationData.title;
            self.applicationData.title = @"";
            
            [_easyController setHttpMethod:MyHttpMethodGet];
        }
        else if ([[buttonCell title] isEqualToString:@"POST"]) {
            
            if ([self.applicationData.title isEqualToString:@""]) {
                self.applicationData.title = self.applicationData.placeholderString;
            }

            [_easyController setHttpMethod:MyHttpMethodPost];
        }
        else if ([[buttonCell title] isEqualToString:@"PUT"]) {
            
            if ([self.applicationData.title isEqualToString:@""]) {
                self.applicationData.title = self.applicationData.placeholderString;
            }

            [_easyController setHttpMethod:MyHttpMethodPut];
        }
        else if ([[buttonCell title] isEqualToString:@"DELETE"]) {
            [_easyController setHttpMethod:MyHttpMethodDelete];
        }
        
        NSLog(@"HTTP method selected: %@ %@", [sender stringValue], [buttonCell title]);
    }
}

- (IBAction)applicationDataSentAction:(id)sender {
    // Application data edited.
    self->_docBuf = [sender stringValue];
}

- (IBAction)popupReplicateWindow:(id)sender {
    // To Avoid loading nib every time every time.
    // From: http://www.cocoabuilder.com/archive/cocoa/133809-nswindowcontroller-window-always-nil.html
    /*
     > I can't figure out why [self window] always return nil, even if the
     > window has already been displayed. Am I missing something?
     
     Have you dragged the connection from the window controller (files
     owner) and the window in the nib file?
     MJ Note: click on files owner and select NSWindowController as the class in the identity inspector.
     This will make a window outlet appear in the connections inspector.
     Then drag window outlet to the window in the interface builder GUI.
     (i.e the graphical cocoa window not the Window icon in the left column).
     */

    if (_replicateWindowController == nil) {
        // Lazy loading.
        _replicateWindowController = [[NSWindowController alloc] initWithWindowNibName: @"ReplicateWindow" owner:self];
    }
    
    [_replicateWindowController showWindow:self];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    // NSArray *cellArray = [self.httpVerb cells];
    // [[cellArray objectAtIndex:0] setTitle:@"Apples"];
    [self.httpVerb selectCellAtRow:0 column:0];
    
    // FIX ME - this is error prone.
    [_easyController setHttpMethod:MyHttpMethodGet];
    
    // Review: there must be a better way.
    if (self->_docBuf != nil) {
        self.applicationData.placeholderString = self->_docBuf;
    }

}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    // [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    if (self->_docBuf == nil) {
        return nil;
    }
    
    NSData* doc = [self->_docBuf dataUsingEncoding:NSUTF8StringEncoding];
    if (doc == nil && outError != nil) {
        NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
        NSString *desc = NSLocalizedString(@"Couldn't convert to UTF8", nil);
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        
        *outError = [NSError errorWithDomain:domain
                                             code:-101
                                         userInfo:userInfo];
    }
    
    return doc;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    // [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    
    NSString* buf = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (buf == nil) {
        // FIX ME - set outError.
        return NO;
    }
    
    self->_docBuf = buf;
    NSLog(@"Loaded Data type: %@", typeName);
    
    return YES;
}


@end
