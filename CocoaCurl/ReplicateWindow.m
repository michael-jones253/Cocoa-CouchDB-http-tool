//
//  ReplicateWindow.m
//  CocoaCurl
//
//  Created by Michael Jones on 23/05/2015.
//  Copyright (c) 2015 Michael Jones. All rights reserved.
//
#import "ReplicateWindow.h"
#import "MyEasyController.h"
#import <Foundation/Foundation.h>

@interface ReplicateWindow ()
@property MyEasyController* easyController;
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

- (void)awakeFromNib {
    NSLog(@"AWAKE FROM NIB");
    // [self addObserver:self.parentWindow forKeyPath:@"labelKey" options:NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)getDbsButtonPressed:(id)sender {
    
    [self.localDbs removeAllItems];
    [self.remoteDbs removeAllItems];
    
    NSError* getError;
    NSArray *databaseNames = [_easyController GetDbNamesForHost:@"127.0.0.1" error:&getError];
    [self.localDbs addItemsWithObjectValues:databaseNames];

    NSString* remoteHostName = [self.remoteHost stringValue];
    databaseNames = [_easyController GetDbNamesForHost:remoteHostName error:&getError];
    [self.remoteDbs addItemsWithObjectValues:databaseNames];
}

- (IBAction)replicateButtonPressed:(id)sender {
    // TO DO.
}

@end

