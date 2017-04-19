//
//  ViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEBluetoothDefine.h"

#import "HEBluetooth.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSArray <CBUUID *> *scanForPeripheralsWithServices = nil;   // @[];
    NSDictionary <NSString *, id> *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary <NSString *, id> *connectPeripheralWithOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES};
    NSArray <CBUUID *> *discoverWithServices = nil; // @[];
    NSArray <CBUUID *> *discoverWithCharacteristics = nil;  // @[];
    
    [[HEBluetooth shareBluetooth] setOptionsWithScanForPeripheralsWithServices:scanForPeripheralsWithServices
                                                 scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                                                  connectPeripheralWithOptions:connectPeripheralWithOptions
                                                          discoverWithServices:discoverWithServices
                                                   discoverWithCharacteristics:discoverWithCharacteristics];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
