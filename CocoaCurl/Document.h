//
//  Document.h
//  CocoaCurl
//
//  Created by Michael Jones on 9/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#import "MyCocoaCurl.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Document : NSDocument {
    NSString* _docBuf;
}

@property(weak, nonatomic) IBOutlet NSTextFieldCell *url;
@property(weak, nonatomic) IBOutlet NSTextFieldCell *applicationData;
@property(weak, nonatomic) IBOutlet NSMatrix *httpVerb;
@property(weak, nonatomic) IBOutlet NSButtonCell *attachAsPlainText;
@property(weak, nonatomic) IBOutlet NSButtonCell *dump;

@property(nonatomic) IBOutlet NSTextView *content;

@property NSString* imagePath;

- (IBAction)curlButtonTapped:(id)sender;
- (IBAction)loadImageButtonTapped:(id)sender;
- (IBAction)copyButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)exampleViewButtonPressed:(id)sender;
- (IBAction)httpMethodButtonSelected:(id)sender;
- (IBAction)applicationDataSentAction:(id)sender;
- (IBAction)popupReplicateWindow:(id)sender;

@end

