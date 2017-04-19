//
//  HEBluetoothBridge.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/19.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEBluetoothBridge.h"
#import "HEBluetoothOptions.h"
#import "HEBluetoothCallback.h"

@implementation HEBluetoothBridge
- (instancetype)init
{
    self = [super init];
    if (self) {
        _callback = [[HEBluetoothCallback alloc] init];
    }
    return self;
}

@end
