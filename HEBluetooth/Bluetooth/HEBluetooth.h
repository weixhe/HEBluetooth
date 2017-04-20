//
//  HEBluetooth.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HECentralManager.h"
#import "HEBluetoothBridge.h"
#import "HEBluetoothCallback.h"

@interface HEBluetooth : NSObject

/*!
 *  @brief 单例，保证程序中只出现一个对象，控制蓝牙
 */
+ (instancetype)shareBluetooth;

/*!
 *  @brief 初始化,设置option：中心设备扫描外设的配置
 *  @param  scanForPeripheralsWithServices 扫描特定外设数组, 用于扫描一个特定ID的外设, 数组中放服务ID：‘CBUUID’，硬件蓝牙上的某个服
 *  @param  scanForPeripheralsWithOptions 扫描属性，             see：HEBluetoothOptions -> scanForPeripheralsWithOptions
 *  @param  connectPeripheralWithOptions 连接设备的参数字典，      see：HEBluetoothOptions -> connectPeripheralWithOptions
 *  @param  discoverWithServices 发现外设的服务，                 see：HEBluetoothOptions -> discoverWithServices
 *  @param  discoverWithCharacteristics 发现外设服务中的的特征     see：HEBluetoothOptions -> discoverWithCharacteristics
 */
- (void)setOptionsWithScanForPeripheralsWithServices:(NSArray <CBUUID *> *)scanForPeripheralsWithServices
                       scanForPeripheralsWithOptions:(NSDictionary <NSString *, id> *)scanForPeripheralsWithOptions
                        connectPeripheralWithOptions:(NSDictionary <NSString *, id> *) connectPeripheralWithOptions
                                discoverWithServices:(NSArray <CBUUID *> *)discoverWithServices
                         discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics;


#pragma mark - 属性
@property (nonatomic, strong, readonly) HECentralManager *centralManager;


#pragma mark - Block - CBCentralManagerDelegate

/*!
 *   @brief 在初始化管理中心完成后，会回调代理中的如下方法，我们必须实现如下方法，
 *          这个方法中可以获取到管理中心的状态
 */
- (void)setBlockOnCentralManagerDidUpdateState:(HECentralManagerDidUpdateStateBlock)block;

/*!
 *   @brief 开始扫描，包含了扫描时间和是否停止扫描
 */
- (void)setBlockOnScanPeripherals:(HECentralManagerDidScanPeripherals)block;

/*!
 *   @brief 扫描的结果, peripheral:扫描到的外设, advertisementData:外设发送的广播数据, RSSI:信号强度
 */
- (void)setBlockOnDiscoverToPeripherals:(HECentralDiscoverPeripheralsBlock)block;

/*!
 *   @brief 连接到Peripherals-成功
 */
- (void)setBlockOnConnected:(HECentralSuccessConnectPeripheralBlock)block;

/*!
 *   @brief 连接到Peripherals-失败
 */
- (void)setBlockOnFailToConnect:(HECentralFailConnectPeripheralBlock)block;

/*!
 *   @brief 断开与外设的连接
 */
- (void)setBlockOnDisconnect:(HECentralDisconnectPeripheralBlock)block;


#pragma mark - Block - CBPeripheralDelegate

/*!
 *   @brief 外设名称更改时回调的方法
 */
- (void)setBlockOnDidUpdateName:(HEPeripheralDidUpdateNameBlock)block;

/*!
 *   @brief 外设服务变化时回调的方法
 */
- (void)setBlockOnDidModifyServices:(HEPeripheralDidModifyServicesBlock)block;

/*!
 *   @brief 信号强度改变时调用的方法, ios < 8时会走，基本弃用
 */
- (void)setBlockOnDidReadRSSI:(HEPeripheralDidUpdateRSSIBlock)block;

/*!
 *   @brief 发现服务时调用的方法
 */
- (void)setBlockOnDiscoverServices:(HEPeripheralDiscoverServicesBlock)block;

/*!
 *   @brief 在服务中发现子服务回调的方法
 */
- (void)setBlockOnDidDiscoverIncludedServicesForService:(HEPeripheralDidDiscoverIncludedServicesForServiceBlock)block;

/*!
 *   @brief 发现服务的特征值后回调的方法
 */
- (void)setBlockOnDiscoverCharacteristics:(HEPeripheralDiscoverCharacteristicsBlock)block;

/*!
 *   @brief 特征值读取（更新）时回调的方法
 */
- (void)setBlockOnReadValueForCharacteristic:(HEPeripheralReadValueForCharacteristicBlock)block;

/*!
 *   @brief 向特征值写数据时回调的方法
 */
- (void)setBlockOnDidWriteValueForCharacteristic:(HEPeripheralWriteValueForCharacteristicBlock)block;

/*!
 *   @brief 特征值的通知设置改变时触发的方法
 */
- (void)setBlockOnDidUpdateNotificationStateForCharacteristic:(HEPeripheralDidUpdateNotificationStateForCharacteristicBlock)block;

/*!
 *   @brief 发现特征值的描述信息触发的方法
 */
- (void)setBlockOnDiscoverDescriptorsForCharacteristic:(HEPeripheralDiscoverDescriptorsForCharacteristicBlock)block;

/*!
 *   @brief 特征的描述值更新时触发的方法
 */
- (void)setBlockOnReadValueForDescriptors:(HEPeripheralReadValueForDescriptorsBlock)block;

/*!
 *   @brief 写描述信息时触发的方法
 */
- (void)setBlockOnDidWriteValueForDescriptor:(HEPeripheralWriteValueForDescriptorsBlock)block;

#pragma mark - CentalManager Tools
/*!
 *   @brief 开始扫描周围外设, 每5s尝试扫描一次，默认有5次机会 @see keyForCentalManagerWaitForOpenBluetooth
 */
- (void)scanPeripherals;

/*!
 *   @brief 从外设的某个特征中读取详细内容
 */
- (void)readCharacteristicForPeripheral:(CBPeripheral *)peripheral charaterist:(CBCharacteristic *)charaterist;
@end
