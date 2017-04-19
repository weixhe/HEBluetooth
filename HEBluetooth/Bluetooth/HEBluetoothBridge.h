//
//  HEBluetoothBridge.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/19.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEBluetoothOptions.h"
#import "HEBluetoothCallback.h"
/*!
 *   @brief 蓝牙通讯的桥梁，连接central与callback、options
 */
@interface HEBluetoothBridge : NSObject

@property (nonatomic, strong, readonly) HEBluetoothOptions *options;

@property (nonatomic, strong, readonly) HEBluetoothCallback *callback;

@end
