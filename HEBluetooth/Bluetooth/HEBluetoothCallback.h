//
//  HEBluetoothCallback.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/19.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEBluetoothDefine.h"
#import <CoreBluetooth/CoreBluetooth.h>

//================================================================================

// 中心设备状态改变
typedef void (^HECentralManagerDidUpdateStateBlock)(HEBluetoothState bluetoothState);

// 中心设备开始扫描
typedef void(^HECentralManagerDidScanPeripherals)(CBCentralManager *central, NSInteger timeInsterval, BOOL *stop);

// 中心设备停止扫描回调
typedef void(^HECentralCancelScanBlock)(CBCentralManager *centralManager);

// 中心设备扫描到设备回调
typedef void(^HECentralDiscoverPeripheralsBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

// 中心设备连接设备-成功
typedef void (^HECentralSuccessConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral);

// 中心设备连接设备-失败
typedef void (^HECentralFailConnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);

// 中心设备连接设备-断开
typedef void (^HECentralDisconnectPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);

// 中心设备所有连接设备 - 断开
typedef void (^HECentralAllPeripheralsDisconnectionBlock)(CBCentralManager *centralManager);



//====

// 外设(设备)改变名字
typedef void(^HEPeripheralDidUpdateNameBlock)(CBPeripheral *peripheral);

// 外设(设备)改变服务
typedef void (^HEPeripheralDidModifyServicesBlock)(CBPeripheral *peripheral, NSArray *invalidatedServices);

// 外设(设备)信号强度改变
typedef void(^HEPeripheralDidUpdateRSSIBlock)(NSNumber *RSSI, NSError *error);

// 外设(设备)读取信号强度
typedef void (^HEPeripheralDidReadRSSIBlock)(NSNumber *RSSI, NSError *error);

// 外设(设备)发现了服务
typedef void (^HEPeripheralDiscoverServicesBlock)(CBPeripheral *peripheral, NSError *error);

// 外设(设备)在服务中发现子服务
typedef void (^HEPeripheralDidDiscoverIncludedServicesForServiceBlock)(CBService *service, NSError *error);

// 外设(设备)发现服务中的特征
typedef void (^HEPeripheralDiscoverCharacteristicsBlock)(CBPeripheral *peripheral, CBService *service, NSError *error);

// 外设(设备)更新（获取）特征值
typedef void (^HEPeripheralReadValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

// 外设(设备)写入特征值
typedef void (^HEPeripheralWriteValueForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

// 外设(设备)特征值通知改变
typedef void (^HEPeripheralDidUpdateNotificationStateForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

// 外设(设备)发现特征值的描述信息
typedef void (^HEPeripheralDiscoverDescriptorsForCharacteristicBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);

// 外设(设备)读取特征值的描述信息
typedef void (^HEPeripheralReadValueForDescriptorsBlock)(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error);

// 外设(设备)写入特征值的描述信息
typedef void (^HEPeripheralWriteValueForDescriptorsBlock)(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error);


//================================================================================

@interface HEBluetoothCallback : NSObject
// 中心设备状态改变
@property (nonatomic, copy) HECentralManagerDidUpdateStateBlock blockOnUpdateCentralState;

// 开始扫描
@property (nonatomic, copy) HECentralManagerDidScanPeripherals blockOnDidScanPerippherals;

// 停止扫描回调
@property (nonatomic, copy) HECentralCancelScanBlock blockOnCancelScan;

// 中心设备扫描到设备回调
@property (nonatomic, copy) HECentralDiscoverPeripheralsBlock blockOnDiscoverPeripheral;

// 中心设备连接设备-成功回调
@property (nonatomic, copy) HECentralSuccessConnectPeripheralBlock blockOnSuccessConnectPeripheral;

// 中心设备连接设备-失败回调
@property (nonatomic, copy) HECentralFailConnectPeripheralBlock blockOnFailConnectPeripheral;

// 中心设备-断开连接回调
@property (nonatomic, copy) HECentralDisconnectPeripheralBlock blockOnDisConnectPeripheral;

// 中心设备所有连接设备 - 断开
@property (nonatomic, copy) HECentralAllPeripheralsDisconnectionBlock blockOnAllPeripheralDisconnectioned;



//====
// 外设(设备)名字改变
@property (nonatomic, copy) HEPeripheralDidUpdateNameBlock blockOnUpdatePeripheralName;

// 外设(设备)改变服务
@property (nonatomic, copy) HEPeripheralDidModifyServicesBlock blockOnModifyPeripheralServices;

// 外设(设备)改变信号强度
@property (nonatomic, copy) HEPeripheralDidUpdateRSSIBlock blockOnUpdatePeripheralRSSI;

// 外设(设备)读取信号强度
@property (nonatomic, copy) HEPeripheralDidReadRSSIBlock blockOnReadPeripheralRSSI;

// 外设(设备)发现了服务
@property (nonatomic, copy) HEPeripheralDiscoverServicesBlock blockOnDiscoverServices;

// 外设(设备)在服务中发现子服务
@property (nonatomic, copy) HEPeripheralDidDiscoverIncludedServicesForServiceBlock blockOnDidDiscoverIncludedServicesForService;

// 外设(设备)发现服务中的特征
@property (nonatomic, copy) HEPeripheralDiscoverCharacteristicsBlock blockOnDiscoverCharacteristics;

// 外设(设备)更新（获取）特征值
@property (nonatomic, copy) HEPeripheralReadValueForCharacteristicBlock blockOnReadValueForCharacteristic;

// 外设(设备)写入特征值
@property (nonatomic, copy) HEPeripheralWriteValueForCharacteristicBlock blockOnWriteValueForCharacteristic;

// 外设(设备)特征值通知改变
@property (nonatomic, copy) HEPeripheralDidUpdateNotificationStateForCharacteristicBlock blockOnDidUpdateNotificationStateForCharacteristic;

// 外设(设备)发现特征值的描述信息
@property (nonatomic, copy) HEPeripheralDiscoverDescriptorsForCharacteristicBlock blockOnDiscoverDescriptorsForCharacteristic;

// 外设(设备)读取特征值的描述信息
@property (nonatomic, copy) HEPeripheralReadValueForDescriptorsBlock blockOnReadValueForDescriptors;

// 外设(设备)写入特征值的描述信息
@property (nonatomic, copy) HEPeripheralWriteValueForDescriptorsBlock blockOnWriteValueForDescriptors;

@end
