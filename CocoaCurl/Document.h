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
}

@property (weak) IBOutlet NSTextFieldCell *url;
@property (weak) IBOutlet NSTextFieldCell *applicationData;
@property (weak) IBOutlet NSTextFieldCell *content;
@property (weak) IBOutlet NSMatrix *httpVerb;
@property (weak) IBOutlet NSButtonCell *attachAsPlainText;

- (IBAction)curlButtonTapped:(id)sender;
- (IBAction)copyButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)exampleViewButtonPressed:(id)sender;
- (IBAction)httpMethodButtonSelected:(id)sender;

@end

