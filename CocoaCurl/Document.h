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
    MyEasyController* _easyController;
    NSString* _docBuf;
}

@property (weak) IBOutlet NSTextFieldCell *url;
@property (weak) IBOutlet NSTextFieldCell *applicationData;
@property (weak) IBOutlet NSTextFieldCell *content;
@property (weak) IBOutlet NSMatrix *httpVerb;
@property (weak) IBOutlet NSButtonCell *attachAsPlainText;
@property (weak) IBOutlet NSButtonCell *dump;
@property NSString* imagePath;

- (IBAction)curlButtonTapped:(id)sender;
- (IBAction)loadImageButtonTapped:(id)sender;
- (IBAction)copyButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)exampleViewButtonPressed:(id)sender;
- (IBAction)httpMethodButtonSelected:(id)sender;
- (IBAction)applicationDataSentAction:(id)sender;

@end

