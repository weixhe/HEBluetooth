//
//  HEBluetooth.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEBluetooth : NSObject

/*!
 *  @brief 单例，保证程序中只出现一个对象，控制蓝牙
 */
+ (instancetype)shareBluetooth;

@end
