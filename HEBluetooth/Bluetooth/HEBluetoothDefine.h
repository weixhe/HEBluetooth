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

#define keyForCentalRestoreIdentify                         @"com.weixhe.hebluetooth.centalManager.restoreIdentify"


/// 当前系统版本大于等于某版本
#define IOS_Equal_or_Above(v) (([[[UIDevice currentDevice] systemVersion] floatValue] >= (v))? (YES):(NO))
/// 当前系统版本小于等于某版本
#define IOS_Equal_or_Below(v) (([[[UIDevice currentDevice] systemVersion] floatValue] <= (v))? (YES):(NO))

#define isIOS6  ([[[UIDevice currentDevice] systemVersion] intValue] == 6 ? (YES):(NO))
#define isIOS7  ([[[UIDevice currentDevice] systemVersion] intValue] == 7 ? (YES):(NO))
#define isIOS8  ([[[UIDevice currentDevice] systemVersion] intValue] == 8 ? (YES):(NO))
#define isIOS9  ([[[UIDevice currentDevice] systemVersion] intValue] == 9 ? (YES):(NO))
#define isIOS10 ([[[UIDevice currentDevice] systemVersion] intValue] == 10 ? (YES):(NO))

#endif /* HEBluetoothDefine_h */
