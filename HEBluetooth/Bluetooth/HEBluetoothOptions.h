//
//  HEBluetoothOptions.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/19.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
/*!
 *   @brief 总结蓝牙连接需要使用到的option，
 */
@interface HEBluetoothOptions : NSObject

#pragma mark - 属性

/*!
 *  @brief 扫描特定外设数组, 用于扫描一个特定ID的外设, 数组中放服务ID：‘CBUUID’，硬件蓝牙上的某个服务
 *  [centralManager scanForPeripheralsWithServices:self.scanForPeripheralsWithServices options:self.scanForPeripheralsWithOptions];
 */
@property (nonatomic, copy) NSArray <CBUUID *> *scanForPeripheralsWithServices;

/*!
 *  扫描属性字典, 用到的key：
 *  CBCentralManagerScanOptionAllowDuplicatesKey        : 是否允许重复扫描 对应NSNumber的bool值，默认为NO，会自动去重
 *  CBCentralManagerScanOptionSolicitedServiceUUIDsKey  : 要扫描的设备UUID 数组
 *  [centralManager scanForPeripheralsWithServices:self.scanForPeripheralsWithServices options:self.scanForPeripheralsWithOptions];
 */
@property (nonatomic, copy) NSDictionary <NSString *, id> *scanForPeripheralsWithOptions;

/*!
 *  连接设备的参数字典
 *  CBConnectPeripheralOptionNotifyOnConnectionKey      : 对应NSNumber的bool值，设置当外设连接后是否弹出一个警告
 *  CBConnectPeripheralOptionNotifyOnDisconnectionKey   : 对应NSNumber的bool值，设置当外设断开连接后是否弹出一个警告
 *  CBConnectPeripheralOptionNotifyOnNotificationKey    : 对应NSNumber的bool值，设置当外设暂停连接后是否弹出一个警告
 */
@property (nonatomic, copy) NSDictionary <NSString *, id> *connectPeripheralWithOptions;

// =================================================================================

/*!
 *   @brief 发现外设的服务
 *  [peripheral discoverServices:self.discoverWithServices];
 */
@property (nonatomic, copy) NSArray <CBUUID *> *discoverWithServices;

/*!
 *   @brief 发现外设的服务中的子服务
 *  [peripheral discoverIncludedServices:self.discoverWithServicesIncludedServices forService:service];
 */
@property (nonatomic, copy) NSArray <CBUUID *> *discoverWithServicesIncludedServices;

/*!
 *   @brief 发现外设服务中的的特征、特性
 *  [peripheral discoverCharacteristics:self.discoverWithCharacteristics forService:service];
 */
@property (nonatomic, copy) NSArray *discoverWithCharacteristics;


#pragma mark - Initial

@end
