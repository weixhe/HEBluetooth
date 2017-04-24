//
//  HECentralManager.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEBluetoothDefine.h"

/*!
 *   @brief 中心设备管理中心，蓝牙连接时，必须有一个设备充当中心设备，扫描。连接其他的设备（外设），关系：一个中心设备 -> 一个或多个外设 -> 一个或多个服务 -> 一个或多个特征 -> 一个或多个特征描述
 */
@class HEBluetoothBridge;

@interface HECentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

#pragma mark - 属性
@property (nonatomic, strong, readonly) HEBluetoothBridge *bridge;

@property (nonatomic, assign) BOOL autoConnectPeripheral;               // 是否自动连接外设

@property (nonatomic, assign) BOOL autoDiscoverServices;                // 是否自动查找服务

@property (nonatomic, assign) BOOL autoDiscoverIncludedServices;        // 是否自动查找服务中的子服务

@property (nonatomic, assign) BOOL autoReconnectPeripheral;             // 是否自动重新连接外设（已断开的或存在历史连接的）, 默认: YES

@property (nonatomic, assign) BOOL autoDiscoverCharacteristics;         // 是否自动查找服务中的特征、特性
@property (nonatomic, assign) BOOL autoReadValueForCharacteristic;      // 是否获取（更新）Characteristics的值

@property (nonatomic, assign) BOOL autoDiscoverDescriptors;             // 是否需要寻找特征的描述值
@property (nonatomic, assign) BOOL autoReadValueForDescriptors;         // 是否需要获取（更新）特征值的描述值
@property (nonatomic, assign) BOOL onlyReadOnceValueForDescriptors;     // 只读取一次特征的描述值，当其值为YES时， autoReadValueForDescriptors会暂时屏蔽

// 蓝牙状态
@property (nonatomic, assign, readonly) HEBluetoothState bluetoothState;


#pragma mark - Method
/*!
 *   @brief 扫描Peripherals
 */
- (void)scanPeripherals;

/*!
 *   @brief 停止扫描
 */
- (void)cancelScan;

/*!
 *   @brief 连接Peripherals
 */
- (void)connectToPeripheral:(CBPeripheral *)peripheral;

/*!
 *   @brief 断开设备连接
 */
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

/*!
 *   @brief 断开所有已连接的设备
 */
- (void)cancelAllPeripheralsConnection;

/*!
 *   @brief 返回所有搜索到的、已连接的、需要自动连接的设备
 */
- (NSArray *)findAllDiscoverPeripherals;
- (NSArray *)findAllConnectedPeripheral;

/*!
 *   @brief 忽略历史连接设备中的某个设备，不自动连接
 */
- (void)ignorePeripheralFromHistory:(CBPeripheral *)peripheral;
@end
