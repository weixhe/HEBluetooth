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

@property (nonatomic, strong, readonly) CBPeripheralManager *peripheralManager;   // 外设管理器

@property (nonatomic, copy, readonly) NSString *localName;                // 设备名称

@property (nonatomic, strong, readonly) NSArray *services;         // 设备服务

@property (nonatomic, strong, readonly) NSData *advertisementData;         // 设备广播包数据

@property (nonatomic, assign, readonly) HEBluetoothState bluetoothState;  // 蓝牙状态

#pragma mark - Method

/*!
 *   @brief 添加一些服务，参数：数组
 */
- (void)addServices:(NSArray *)services;

/*!
 *  @brief 删除某一个服务
 */
- (void)removeServices:(CBMutableService *)service;

/*!
 *   @brief 删除所有的服务
 */
- (void)removeAllServices;

/*!
 *   @brief 添加一个广播包，连接到设备时可以读取到
 */
- (void)addManufacturerData:(NSData *)data;

/*!
 *  @brief 启动广播
 */
- (void)startAdvertising;

/*!
 *   @brief 停止广播
 */
- (void)stopAdvertising;

@end


/*！
 *  @brief 生成一个服务的特征，包含了数据data和只读（只写、通知、读写）性，特征中又包含了一个描述值
 *  param`ter for properties ：option 'r' | 'w' | 'n' or combination
 *	r                       CBCharacteristicPropertyRead
 *	w                       CBCharacteristicPropertyWrite
 *	n                       CBCharacteristicPropertyNotify
 *  default value is rw     Read-Write
 */
void makeCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *properties, NSString *descriptor);

/*！
 *  构造一个包含初始值的Characteristic，并加入service,包含了初值的characteristic必须设置permissions和properties都为只读
 */
void makeStaticCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *descriptor, NSData *data);

/*!
 *   @brief 根据UUID生成一个服务
 */
CBMutableService * makeCBService(NSString *UUID);

/*!
 *   @brief 生成一个UUID
 */
NSString *genUUID();
