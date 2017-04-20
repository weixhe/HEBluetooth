//
//  HEPeripheralManager.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/20.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEBluetoothDefine.h"

/*!
 *   @brief 外设管理中心，即将手机当做一个外设
 */
@class HEBluetoothBridge;
@interface HEPeripheralManager : NSObject <CBPeripheralManagerDelegate>

#pragma mark - 属性
@property (nonatomic, strong, readonly) HEBluetoothBridge *bridge;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;   // 外设管理器

@property (nonatomic, copy) NSString *localName;                // 设备名称

@property (nonatomic, strong) NSMutableArray *services;         // 设备服务

@property (nonatomic, strong) NSData *manufacturerData;         // 设备广播包数据

#pragma mark - Method


@end


/**
 *  构造Characteristic，并加入service
 *  service:CBService
 
 *  param`ter for properties ：option 'r' | 'w' | 'n' or combination
 *	r                       CBCharacteristicPropertyRead
 *	w                       CBCharacteristicPropertyWrite
 *	n                       CBCharacteristicPropertyNotify
 *  default value is rw     Read-Write
 
 *  paramter for descriptor：be uesd descriptor for characteristic
 */

void makeCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *properties, NSString *descriptor);

/**
 *  构造一个包含初始值的Characteristic，并加入service,包含了初值的characteristic必须设置permissions和properties都为只读
 *  make characteristic then add to service, a static characteristic mean it has a initial value .according apple rule, it must set properties and permissions to CBCharacteristicPropertyRead and CBAttributePermissionsReadable
 */
void makeStaticCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *descriptor, NSData *data);
/**
 生成CBService
 */
CBMutableService * makeCBService(NSString *UUID);

/**
 生成UUID
 */
NSString * genUUID();
