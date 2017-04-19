//
//  HEBluetooth.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEBluetooth.h"

@interface HEBluetooth ()

@end

static HEBluetooth *instance = nil;
@implementation HEBluetooth

/*!
 *  @brief 单例，保证程序中只出现一个对象，控制蓝牙
 */
+ (instancetype)shareBluetooth {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HEBluetooth alloc] init];
    });
    return instance;
}


@end
