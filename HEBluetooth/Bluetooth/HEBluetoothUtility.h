//
//  HEBluetoothUtility.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 *  @brief 蓝牙工具类，公共类
 */
@interface HEBluetoothUtility : NSObject

/*!
 *   @brief 检查扫描到的外设是否正确
 */
+ (BOOL)filterOnDiscoverPeripheral:(CBPeripheral *)peripheral;

@end
