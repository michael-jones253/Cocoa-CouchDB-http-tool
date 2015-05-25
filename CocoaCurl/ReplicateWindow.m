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
}

- (IBAction)getDbsButtonPressed:(id)sender {
    
    [self.localDbs removeAllItems];
    [self.remoteDbs removeAllItems];
    
    NSError* getError;
    NSArray *databaseNames = [_easyController GetDbNamesForHost:@"127.0.0.1" error:&getError];
    
    if (getError != nil) {
        NSAlert *alert = [NSAlert alertWithError:getError];
        [alert runModal];
        return;
    }

    [self.localDbs addItemsWithObjectValues:databaseNames];

    NSString* remoteHostName = [self.remoteHost stringValue];
    databaseNames = [_easyController GetDbNamesForHost:remoteHostName error:&getError];
    if (getError != nil) {
        NSAlert *alert = [NSAlert alertWithError:getError];
        [alert runModal];
        return;
    }

    [self.remoteDbs addItemsWithObjectValues:databaseNames];
}

- (IBAction)replicateButtonPressed:(id)sender {
    switch (_replicateOperation) {
        case PushCreate:
            break;
            
        case PushSync:
            break;
            
        case PullCreate:
            break;
            
        case PullSync:
            break;
            
        default:
            break;
    }
}

- (IBAction)replicateOperationSelected:(id)sender {
    [self determinOperation];
}

- (IBAction)dbChoiceSelected:(id)sender {
    // TO DO.
    NSComboBoxCell* cell = [self.localDbs selectedCell];
    NSString* localDbName = [cell stringValue];
    
    cell = [self.remoteDbs selectedCell];
    NSString* remoteDbName = [cell stringValue];
    
    switch (_replicateOperation) {
        case PushCreate:
            break;
            
        case PushSync:
            break;
            
        case PullCreate:
            break;
            
        case PullSync:
            break;
            
        default:
            break;
    }
}

- (void)determinOperation {
    NSInteger selectedRow = [self.operation selectedRow];
    _replicateOperation = (enum ReplicateOperation)selectedRow;
    
    NSAssert(_replicateOperation >= PushCreate && _replicateOperation <= PullSync, @"Replicate selection not valid.");
}

@end

