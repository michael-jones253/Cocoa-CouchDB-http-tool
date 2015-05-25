//
//  ReplicateWindow.h
//  CocoaCurl
//
//  Created by Michael Jones on 23/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//

#ifndef CocoaCurl_ReplicateWindow_h
#define CocoaCurl_ReplicateWindow_h

#import <Cocoa/Cocoa.h>

@interface ReplicateWindow : NSWindow

@property (nonatomic) IBOutlet NSMatrix* operation;
@property (nonatomic) IBOutlet NSTextField *remoteHost;
@property (nonatomic) IBOutlet NSTextFieldCell *localDbName;
@property (nonatomic) IBOutlet NSTextFieldCell *remoteDbName;

@property (nonatomic) IBOutlet NSComboBox* localDbs;
@property (nonatomic) IBOutlet NSComboBox* remoteDbs;

- (IBAction)getDbsButtonPressed:(id)sender;
- (IBAction)replicateButtonPressed:(id)sender;
- (IBAction)replicateOperationSelected:(id)sender;
- (IBAction)dbChoiceSelected:(id)sender

@end

#endif
