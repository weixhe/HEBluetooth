//
//  HEPeripheralModel.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEPeripheralModel.h"

@implementation HEPeripheralModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _characteristics = [[NSArray alloc] init];
    }
    return self;
}

@end
