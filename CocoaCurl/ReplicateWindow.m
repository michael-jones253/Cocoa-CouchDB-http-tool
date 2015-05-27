//
//  ReplicateWindow.m
//  CocoaCurl
//
//  Created by Michael Jones on 23/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//
#import "ReplicateWindow.h"
#import "MyEasyController.h"
#import "ReplicateOperation.h"
#import <Foundation/Foundation.h>

@interface ReplicateWindow ()

@property MyEasyController* easyController;

@property enum ReplicateOperation replicateOperation;

- (BOOL)validateUserSelection:(NSError**) selectionError;

- (void)determineOperation;

- (void)setReplicateError:(NSString*const)message error:(NSError**)replicateError;

@end

@implementation ReplicateWindow

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _easyController = [[MyEasyController alloc]init];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        // Add your subclass-specific initialization here.
        _easyController = [[MyEasyController alloc]init];
    }
    
    return self;
}

- (void)awakeFromNib {
    NSLog(@"AWAKE FROM NIB");
    // I don't know why the init methods aren't called.
    _easyController = [[MyEasyController alloc]init];
    
    [self.localDbs removeAllItems];
    [self.remoteDbs removeAllItems];
    [self replicateOperationSelected:self];
}

- (IBAction)getDbsButtonPressed:(id)sender {
    
    [self.localDbs removeAllItems];
    [self.remoteDbs removeAllItems];
    
    NSError* getError;
    NSArray *databaseNames = [_easyController getDbNamesForHost:@"127.0.0.1" error:&getError];
    
    if (getError != nil) {
        NSAlert *alert = [NSAlert alertWithError:getError];
        [alert runModal];
        return;
    }

    [self.localDbs addItemsWithObjectValues:databaseNames];

    NSString* remoteHostName = [self.remoteHost stringValue];
    databaseNames = [_easyController getDbNamesForHost:remoteHostName error:&getError];
    if (getError != nil) {
        NSAlert *alert = [NSAlert alertWithError:getError];
        [alert runModal];
        return;
    }

    [self.remoteDbs addItemsWithObjectValues:databaseNames];
}

- (IBAction)replicateButtonPressed:(id)sender {
    NSError* replicateError;
    
    if (![self validateUserSelection:&replicateError]) {
        NSAlert *alert = [NSAlert alertWithError:replicateError];
        [alert runModal];
        return;
    }

    NSString* localUrl = [NSString stringWithFormat:@"http://127.0.0.1:5984/%@", [self.localDbName stringValue]];
    NSString* remoteUrl = [NSString stringWithFormat:@"http://%@:5984/%@",
                           [self.remoteHost stringValue],
                           [self.remoteDbName stringValue]];
    
    BOOL ok = NO;
    
    switch (_replicateOperation) {
        case PushCreate:
            ok = [_easyController pushReplicateUrl:localUrl destinationUrl:remoteUrl error:&replicateError];
            break;
            
        case PushSync:
            ok = [_easyController pushSyncUrl:localUrl destinationUrl:remoteUrl error:&replicateError];
            break;
            
        case PullCreate:
            ok = [_easyController pullReplicateUrl:localUrl destinationUrl:remoteUrl error:&replicateError];
            break;
            
        case PullSync:
            ok = [_easyController pullSyncUrl:localUrl destinationUrl:remoteUrl error:&replicateError];
            break;
            
        default:
            break;
    }
    
    if (!ok) {
        // Alert seems to handle a nil error.
        NSAlert *alert = [NSAlert alertWithError:replicateError];
        [alert runModal];
    }
    
    [self.response setTitle:[self.easyController getResult]];
}

- (IBAction)replicateOperationSelected:(id)sender {
    [self determineOperation];
    
    switch (_replicateOperation) {
        case PushCreate:
            [self.localDbName setEditable:NO];
            [self.remoteDbName setEditable:YES];
            break;
            
        case PushSync:
            [self.localDbName setEditable:NO];
            [self.remoteDbName setEditable:NO];
            break;
            
        case PullCreate:
            [self.localDbName setEditable:YES];
            [self.remoteDbName setEditable:NO];
            break;
            
        case PullSync:
            [self.localDbName setEditable:NO];
            [self.remoteDbName setEditable:NO];
            break;
            
        default:
            NSAssert(NO, @"Invalid replicate operation");
            break;
    }
}

- (IBAction)dbChoiceSelected:(id)sender {
    NSString* selectedLocalDbName;
    NSComboBoxCell* cell = [self.localDbs selectedCell];
    if (cell != nil) {
        selectedLocalDbName = [cell stringValue];
    }
    
    NSString* selectedRemoteDbName;
    cell = [self.remoteDbs selectedCell];
    if (cell != nil) {
        selectedRemoteDbName = [cell stringValue];
    }
    
    switch (_replicateOperation) {
        case PushCreate:
            [self.localDbName setTitle: selectedLocalDbName];
            break;
            
        case PushSync:
            [self.localDbName setTitle: selectedLocalDbName];
            [self.remoteDbName setTitle: selectedRemoteDbName];
            break;
            
        case PullCreate:
            [self.remoteDbName setTitle: selectedRemoteDbName];
            break;
            
        case PullSync:
            [self.localDbName setTitle: selectedLocalDbName];
            [self.remoteDbName setTitle: selectedRemoteDbName];
            break;
            
        default:
            NSAssert(NO, @"Invalid replicate operation");
            break;
    }
}

- (BOOL)validateUserSelection:(NSError**) selectionError {
    
    if ([[self.remoteHost stringValue] isEqualToString:@""]) {
        [self setReplicateError:@"Remote host must be specified." error:selectionError];
        return NO;
    }
    
    NSInteger remoteTargetIndex = [self.remoteDbs indexOfItemWithObjectValue:[self.remoteDbName stringValue]];
    NSInteger localTargetIndex = [self.localDbs indexOfItemWithObjectValue:[self.localDbName stringValue]];
        
    switch (_replicateOperation) {
        case PushCreate:
            if (remoteTargetIndex != NSNotFound) {
                [self setReplicateError:@"Remote target DB exists - choose sync option" error:selectionError];
                return NO;
            }
            break;
            
        case PushSync:
            if (remoteTargetIndex == NSNotFound) {
                [self setReplicateError:@"Remote target DB not present - choose create option" error:selectionError];
                return NO;
            }
            break;
            
        case PullCreate:
            if (localTargetIndex != NSNotFound) {
                [self setReplicateError:@"Local target DB exists - choose sync option" error:selectionError];
                return NO;
            }
            break;
            
        case PullSync:
            if (localTargetIndex == NSNotFound) {
                [self setReplicateError:@"Local target DB not present - choose create option" error:selectionError];
                return NO;
            }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (void)determineOperation {
    NSInteger selectedRow = [self.operation selectedRow];
    _replicateOperation = (enum ReplicateOperation)selectedRow;
    
    NSAssert(_replicateOperation >= PushCreate && _replicateOperation <= PullSync, @"Replicate selection not valid.");
}

- (void)setReplicateError:(NSString*const)message error:(NSError**)replicateError {
    if (replicateError == nil) {
        return;
    }
    
    NSString *domain = @"com.Jones.CocoaCurl.ErrorDomain";
    NSString *desc = NSLocalizedString(message, nil);
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    
    *replicateError = [NSError errorWithDomain:domain
                                         code:-101
                                     userInfo:userInfo];
}


@end

