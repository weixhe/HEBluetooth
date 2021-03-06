//
//  HEBluetoothDefine.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#ifndef HEBluetoothDefine_h
#define HEBluetoothDefine_h
#import <UIKit/UIKit.h>

//-------------------------------------

#import "HEBluetoothUtility.h"

//-------------------------------------

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define DLog(...)
#endif

/// 当前系统版本大于等于某版本
#define IOS_Equal_or_Above(v) (([[[UIDevice currentDevice] systemVersion] floatValue] >= (v))? (YES):(NO))
/// 当前系统版本小于等于某版本
#define IOS_Equal_or_Below(v) (([[[UIDevice currentDevice] systemVersion] floatValue] <= (v))? (YES):(NO))

#define isIOS6  ([[[UIDevice currentDevice] systemVersion] intValue] == 6 ? (YES):(NO))
#define isIOS7  ([[[UIDevice currentDevice] systemVersion] intValue] == 7 ? (YES):(NO))
#define isIOS8  ([[[UIDevice currentDevice] systemVersion] intValue] == 8 ? (YES):(NO))
#define isIOS9  ([[[UIDevice currentDevice] systemVersion] intValue] == 9 ? (YES):(NO))
#define isIOS10 ([[[UIDevice currentDevice] systemVersion] intValue] == 10 ? (YES):(NO))



// CBCentralManager等待设备打开次数
#define keyForCentalManagerWaitForOpenBluetooth             5

// 后台恢复centralManager的唯一标识
#define keyForCentalRestoreIdentify                         @"com.weixhe.hebluetooth.centalManager.restoreIdentify"


/*!
 *   @brief 蓝牙状态
 */
typedef NS_ENUM(NSUInteger, HEBluetoothState) {
    HEBluetoothStateUnknown,            // 状态未知
    HEBluetoothStateResetting,          // 连接断开 即将重置
    HEBluetoothStateUnsupported,        // 该平台不支持蓝牙
    HEBluetoothStateUnauthorized,       // 未授权蓝牙使用
    HEBluetoothStatePoweredOff,         // 蓝牙关闭
    HEBluetoothStatePoweredOn           // 蓝牙正常开启
};

#endif /* HEBluetoothDefine_h */
