//
//  Document.m
//  CocoaCurl
//
//  Created by Michael Jones on 9/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import "Document.h"

@interface Document ()

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self->_curlCpp = [[MyEasyController alloc]init];
    }
    return self;
}

- (IBAction)curlButtonTapped:(id) sender {
    NSString *name = [sender stringValue];
    if (![name isEqualToString:@""]) {
        
        [self->_curlCpp RunUrl:self.url.title applicationData:self.applicationData.title];
        
        NSLog(@"Performing curl: %@", self.url.title);
        NSString* content = [self->_curlCpp GetResult];
        [self.content setTitle: content];
    }
}

- (IBAction)copyButtonPressed:(id)sender {
    self.applicationData.placeholderString = self.content.title;
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
            
            [_curlCpp setHttpMethod:MyHttpMethodGet];
        }
        else if ([[buttonCell title] isEqualToString:@"POST"]) {
            
            if ([self.applicationData.title isEqualToString:@""]) {
                self.applicationData.title = self.applicationData.placeholderString;
            }

            [_curlCpp setHttpMethod:MyHttpMethodPost];
        }
        else if ([[buttonCell title] isEqualToString:@"PUT"]) {
            
            if ([self.applicationData.title isEqualToString:@""]) {
                self.applicationData.title = self.applicationData.placeholderString;
            }

            [_curlCpp setHttpMethod:MyHttpMethodPut];
        }
        else if ([[buttonCell title] isEqualToString:@"DELETE"]) {
            [_curlCpp setHttpMethod:MyHttpMethodDelete];
        }
        
        NSLog(@"HTTP method selected: %@ %@", [sender stringValue], [buttonCell title]);
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    // NSArray *cellArray = [self.httpVerb cells];
    // [[cellArray objectAtIndex:0] setTitle:@"Apples"];
    [self.httpVerb selectCellAtRow:0 column:0];
    
    // FIX ME - this is error prone.
    [_curlCpp setHttpMethod:MyHttpMethodGet];
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
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}

@end
