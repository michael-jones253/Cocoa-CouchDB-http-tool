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

@property(weak, nonatomic) IBOutlet NSMatrix* operation;
@property(weak, nonatomic) IBOutlet NSTextField *remoteHost;
@property(weak, nonatomic) IBOutlet NSTextFieldCell *localDbName;
@property(weak, nonatomic) IBOutlet NSTextFieldCell *remoteDbName;

@property(weak, nonatomic) IBOutlet NSComboBox* localDbs;
@property(weak, nonatomic) IBOutlet NSComboBox* remoteDbs;

- (IBAction)getDbsButtonPressed:(id)sender;
- (IBAction)replicateButtonPressed:(id)sender;
- (IBAction)replicateOperationSelected:(id)sender;
- (IBAction)dbChoiceSelected:(id)sender;

@end

#endif
