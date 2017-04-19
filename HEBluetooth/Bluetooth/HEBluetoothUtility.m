//
//  HEBluetoothUtility.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEBluetoothUtility.h"

@implementation HEBluetoothUtility

/*!
 *   @brief 检查扫描到的外设是否正确
 */
+ (BOOL)filterOnDiscoverPeripheral:(CBPeripheral *)peripheral {
    // 暂时只检查name，后期如果需要可以添加更多属性的检查
    if (![peripheral.name isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end
