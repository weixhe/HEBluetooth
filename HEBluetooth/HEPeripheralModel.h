//
//  HEPeripheralModel.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HEPeripheralModel : NSObject

@property (nonatomic,strong) CBUUID *serviceUUID;

@property (nonatomic,strong) NSArray *characteristics;

@end
