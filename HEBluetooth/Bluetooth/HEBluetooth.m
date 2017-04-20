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

@property (nonatomic, strong) HEPeripheralManager *peripheralManager;

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
        _centralManager = [[HECentralManager alloc] init];
        _peripheralManager = [[HEPeripheralManager alloc] init];
    }
    return self;
}

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
                        connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
                                discoverWithServices:(NSArray *)discoverWithServices
                         discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    self.centralManager.bridge.options.scanForPeripheralsWithServices   = scanForPeripheralsWithServices;
    self.centralManager.bridge.options.scanForPeripheralsWithOptions    = scanForPeripheralsWithOptions;
    self.centralManager.bridge.options.connectPeripheralWithOptions     = connectPeripheralWithOptions;
    self.centralManager.bridge.options.discoverWithServices             = discoverWithServices;
    self.centralManager.bridge.options.discoverWithCharacteristics      = discoverWithCharacteristics;
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
 *   @brief 开始扫描，包含了扫描时间和是否停止扫描
 */
- (void)setBlockOnScanPeripherals:(HECentralManagerDidScanPeripherals)block {
    self.centralManager.bridge.callback.blockOnDidScanPerippherals = block;
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

#pragma mark - CentalManager Tools
/*!
 *   @brief 开始扫描周围外设, 每5s尝试扫描一次，默认有5次机会（keyForCentalManagerWaitForOpenBluetooth）
 */
- (void)scanPeripherals {
    // 需要判断蓝牙是否已经打开
    if (self.centralManager.bluetoothState == HEBluetoothStatePoweredOn) {
        [self.centralManager scanPeripherals];
        
    } else {
        
        // 蓝牙暂时没有打开，等待中......
        
        int waitForOpenBluetooth = 0;
        
        waitForOpenBluetooth++;
        if (waitForOpenBluetooth >= keyForCentalManagerWaitForOpenBluetooth) {
            DLog(@">>> 第 %d 次等待打开蓝牙任然失败，请检查你蓝牙使用权限或检查设备问题。", waitForOpenBluetooth);
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [self scanPeripherals];
        });
        
        DLog(@">>>第 %d 次等待打开蓝牙！！", waitForOpenBluetooth);
    }
}

//- (void)connectPeripheral:(CBPeripheral *)peripheral autoReadCharacteristic:(BOOL)autoReadCharacteristic {
//    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
//        self.centralManager.autoDiscoverServices = YES;                 // 连接成功后自动发现服务
//        self.centralManager.autoReadValueForCharacteristic = YES;       // 连接成功有直接读取特征值
//        [self.centralManager connectToPeripheral:peripheral];
//    }
//}

/*!
 *   @brief 从外设的某个特征中读取详细内容
 */
- (void)readCharacteristicForPeripheral:(CBPeripheral *)peripheral charaterist:(CBCharacteristic *)charaterist {
    
    if (peripheral.state == CBPeripheralStateConnected) {
        
        self.centralManager.onlyReadOnceValueForDescriptors = YES;      // 仅获取一次特征描述值
        [peripheral readValueForCharacteristic:charaterist];
        [peripheral discoverDescriptorsForCharacteristic:charaterist];
    } else {
        DLog(@"外设 %@ 非连接状态", peripheral.name);
    }
}

////断开连接
//- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
//    [babyCentralManager cancelPeripheralConnection:peripheral];
//}
////断开所有连接
//- (void)cancelAllPeripheralsConnection {
//    [babyCentralManager cancelAllPeripheralsConnection];
//}
////停止扫描
//- (void)cancelScan{
//    [babyCentralManager cancelScan];
//}

#pragma mark - PeripheralManager

/*!
 *  @brief 外设(设备) 添加服务
 */
- (void)setBlockOnDidAddService:(HEPeripheralDidAddService)block {
    self.peripheralManager.bridge.callback.blockOnDidAddService = block;
}

/*!
 *  @brief 外设(设备) 状态改变
 */
- (void)setBlockOnDidUpdateState:(HEPeripheralDidUpdateState)block {
    self.peripheralManager.bridge.callback.blockOnDidUpdateState = block;
}

/*!
 *  @brief 外设(设备) 从后台恢复
 */
- (void)setBlockOnWillRestoreState:(HEPeripheralWillRestoreState)block {
    self.peripheralManager.bridge.callback.blockOnWillRestoreState = block;
}

/*!
 *  @brief 外设（设备）开始广播
 */
- (void)setBlockOnDidStartAdvertising:(HEPeripheralDidStartAdvertising)block {
    self.peripheralManager.bridge.callback.blockOnDidStartAdvertising = block;
}

/*!
 *  @brief 当一个central设备订阅一个特征值时调用
 */
- (void)setBlockOnDidSubscribeToCharacteristic:(HEPeripheralDidSubscribeToCharacteristic)block {
    self.peripheralManager.bridge.callback.blockOnDidSubscribeToCharacteristic = block;
}

/*!
 *  @brief 取消订阅一个特征值时调用的方法
 */
- (void)setBlockOnDidUnsubscribeToCharacteristic:(HEPeripheralDidUnsubscribeToCharacteristic)block {
    self.peripheralManager.bridge.callback.blockOnDidUnsubscribeToCharacteristic = block;
}

/*!
 *  @brief 收到读请求时触发的方法
 */
- (void)setBlockOnDidReceiveReadRequest:(HEPeripheralDidReceiveReadRequest)block {
    self.peripheralManager.bridge.callback.blockOnDidReceiveReadRequest = block;
}

/*!
 *  @brief 收到写请求时触发的方法
 */
- (void)setBlockOnDidReceiveWriteRequests:(HEPeripheralDidReceiveWriteRequests)block {
    self.peripheralManager.bridge.callback.blockOnDidReceiveWriteRequests = block;
}

/*!
 *  @brief 外设准备更新特征值时调用的方法
 */
- (void)setBlockOnIsReadyToUpdateSubscribers:(HEPeripheralDidIsReadyToUpdateSubscribers)block {
    self.peripheralManager.bridge.callback.blockOnIsReadyToUpdateSubscribers = block;
}

@end
