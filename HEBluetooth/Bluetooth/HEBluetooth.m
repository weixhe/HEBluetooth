//
//  HEBluetooth.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEBluetooth.h"

@interface HEBluetooth ()

@property (nonatomic, strong) HECentralManager *centralManager;

@end

static HEBluetooth *instance = nil;
@implementation HEBluetooth

/*!
 *  @brief 单例，保证程序中只出现一个对象，控制蓝牙
 */
+ (instancetype)shareBluetooth {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HEBluetooth alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centralManager = [[HECentralManager alloc] init];
    }
    return self;
}

#pragma mark - Block - CBCentralManagerDelegate

/*!
 *   @brief 在初始化管理中心完成后，会回调代理中的如下方法，我们必须实现如下方法，
 *          这个方法中可以获取到管理中心的状态
 */
- (void)setBlockOnCentralManagerDidUpdateState:(HECentralManagerDidUpdateStateBlock)block {
    self.centralManager.bridge.callback.blockOnUpdateCentralState = block;
}

/*!
 *   @brief 扫描的结果, peripheral:扫描到的外设, advertisementData:外设发送的广播数据, RSSI:信号强度
 */
- (void)setBlockOnDiscoverToPeripherals:(HECentralDiscoverPeripheralsBlock)block {
    self.centralManager.bridge.callback.blockOnDiscoverPeripheral = block;
}

/*!
 *   @brief 连接到Peripherals-成功
 */
- (void)setBlockOnConnected:(HECentralSuccessConnectPeripheralBlock)block {
    self.centralManager.bridge.callback.blockOnSuccessConnectPeripheral = block;
}

/*!
 *   @brief 连接到Peripherals-失败
 */
- (void)setBlockOnFailToConnect:(HECentralFailConnectPeripheralBlock)block {
    self.centralManager.bridge.callback.blockOnFailConnectPeripheral = block;
}

/*!
 *   @brief 断开与外设的连接
 */
- (void)setBlockOnDisconnect:(HECentralDisconnectPeripheralBlock)block {
    self.centralManager.bridge.callback.blockOnDisConnectPeripheral = block;
}

#pragma mark - Block - CBPeripheralDelegate

/*!
 *   @brief 外设名称更改时回调的方法
 */
- (void)setBlockOnDidUpdateName:(HEPeripheralDidUpdateNameBlock)block {
    self.centralManager.bridge.callback.blockOnUpdatePeripheralName = block;
}

/*!
 *   @brief 外设服务变化时回调的方法
 */
- (void)setBlockOnDidModifyServices:(HEPeripheralDidModifyServicesBlock)block {
    self.centralManager.bridge.callback.blockOnModifyPeripheralServices = block;
}

/*!
 *   @brief 信号强度改变时调用的方法, ios < 8时会走，基本弃用
 */
- (void)setBlockOnDidReadRSSI:(HEPeripheralDidUpdateRSSIBlock)block {
    self.centralManager.bridge.callback.blockOnUpdatePeripheralRSSI = block;
}

/*!
 *   @brief 发现服务时调用的方法
 */
- (void)setBlockOnDiscoverServices:(HEPeripheralDiscoverServicesBlock)block {
    self.centralManager.bridge.callback.blockOnDiscoverServices = block;
}

/*!
 *   @brief 在服务中发现子服务回调的方法
 */
- (void)setBlockOnDidDiscoverIncludedServicesForService:(HEPeripheralDidDiscoverIncludedServicesForServiceBlock)block {
    self.centralManager.bridge.callback.blockOnDidDiscoverIncludedServicesForService = block;
}

/*!
 *   @brief 发现服务的特征值后回调的方法
 */
- (void)setBlockOnDiscoverCharacteristics:(HEPeripheralDiscoverCharacteristicsBlock)block {
    self.centralManager.bridge.callback.blockOnDiscoverCharacteristics = block;
}

/*!
 *   @brief 特征值读取（更新）时回调的方法
 */
- (void)setBlockOnReadValueForCharacteristic:(HEPeripheralReadValueForCharacteristicBlock)block {
    self.centralManager.bridge.callback.blockOnReadValueForCharacteristic = block;
}

/*!
 *   @brief 向特征值写数据时回调的方法
 */
- (void)setBlockOnDidWriteValueForCharacteristic:(HEPeripheralWriteValueForCharacteristicBlock)block {
    self.centralManager.bridge.callback.blockOnWriteValueForCharacteristic = block;
}

/*!
 *   @brief 特征值的通知设置改变时触发的方法
 */
- (void)setBlockOnDidUpdateNotificationStateForCharacteristic:(HEPeripheralDidUpdateNotificationStateForCharacteristicBlock)block {
    self.centralManager.bridge.callback.blockOnDidUpdateNotificationStateForCharacteristic = block;
}

/*!
 *   @brief 发现特征值的描述信息触发的方法
 */
- (void)setBlockOnDiscoverDescriptorsForCharacteristic:(HEPeripheralDiscoverDescriptorsForCharacteristicBlock)block {
    self.centralManager.bridge.callback.blockOnDiscoverDescriptorsForCharacteristic = block;
}

/*!
 *   @brief 特征的描述值更新时触发的方法
 */
- (void)setBlockOnReadValueForDescriptors:(HEPeripheralReadValueForDescriptorsBlock)block {
    self.centralManager.bridge.callback.blockOnReadValueForDescriptors = block;
}

/*!
 *   @brief 写描述信息时触发的方法
 */
- (void)setBlockOnDidWriteValueForDescriptor:(HEPeripheralWriteValueForDescriptorsBlock)block {
    self.centralManager.bridge.callback.blockOnWriteValueForDescriptors = block;
}

@end
