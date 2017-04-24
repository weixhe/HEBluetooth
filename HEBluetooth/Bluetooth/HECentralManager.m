//
//  HECentralManager.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HECentralManager.h"
#import "HEBluetoothBridge.h"
#import "HEBluetoothCallback.h"
#import "HEBluetoothOptions.h"

@interface HECentralManager () {
    
    // 存储相关的外设
    NSMutableArray *connectedPeripherals;       // 已经连接的设备、外设
    NSMutableArray *discoverPeripherals;        // 已经连接的设备、外设
    
    NSInteger scanTimeLength;       // 记录扫描时间
    NSInteger tryToScanTimes;       // 尝试连接的次数
}

@property (nonatomic, strong) CBCentralManager *centralManager;         // 中心设备管理器

@property (nonatomic, strong) NSTimer *connectTimer;                    // 连接设备计时器

@property (nonatomic, strong) NSTimer *scanTimer;                       // 扫描设备计时器

@end

@implementation HECentralManager
@synthesize bridge = _bridge;

#pragma mark - Initialize
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self centralManager];
        _bridge = [[HEBluetoothBridge alloc] init];
        connectedPeripherals = [NSMutableArray array];
        discoverPeripherals = [NSMutableArray array];
        self.autoReconnectPeripheral = YES;         // 默认会自动连接设备，已断开的或存在历史连接的
    }
    return self;
}

#pragma mark - Accessors

- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        NSDictionary *option = @{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES],         // 设置是否在关闭蓝牙时弹出用户提示
                                 CBCentralManagerOptionRestoreIdentifierKey:keyForCentalRestoreIdentify};       // 设置管理中心的标识符ID
        
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"bluetooth-central"]) {
            // 后台模式
            // queue: 传入nil为在主线程中进行
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:option];
        } else {
            // 非后台模式
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        }
        [self changeBluetoothState:_centralManager.state];
    }
    return _centralManager;
}

- (HEBluetoothBridge *)bridge {
    if (!_bridge) {
        _bridge = [[HEBluetoothBridge alloc] init];
    }
    return _bridge;
}

#pragma mark - Method
/*!
 *   @brief 扫描Peripherals
 */

- (void)scanPeripherals {
    
    if (self.bluetoothState == HEBluetoothStatePoweredOn) {
        tryToScanTimes = 0;
        // serviceUUIDs用于扫描一个特点ID的外设 options用于设置一些扫描属性，查看：scanForPeripheralsWithServices ， scanForPeripheralsWithOptions
        [self.centralManager scanForPeripheralsWithServices:self.bridge.options.scanForPeripheralsWithServices options:self.bridge.options.scanForPeripheralsWithOptions];
        scanTimeLength = 0;
        [self removeAllDiscoverdPeripheral];

        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanTimerRunning) userInfo:nil repeats:YES];
    } else {
        tryToScanTimes++;
        if (tryToScanTimes > keyForCentalManagerWaitForOpenBluetooth) {

            tryToScanTimes = 0;
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanPeripherals];
        });
    }
}

/*!
 *   @brief 扫描定时器超时，停止扫描
 */
- (void)scanTimerRunning {
    if (self.bridge.callback.blockOnDidScanPerippherals) {
        BOOL stop = NO;
        self.bridge.callback.blockOnDidScanPerippherals(self.centralManager, ++scanTimeLength, &stop);
        if (stop) {
            [self cancelScan];
        }
    }
}

/*!
 *   @brief 连接Peripherals
 */
- (void)connectToPeripheral:(CBPeripheral *)peripheral {
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        [self.centralManager connectPeripheral:peripheral options:self.bridge.options.connectPeripheralWithOptions];
        // 开一个定时器监控连接超时的情况
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimerRunning:) userInfo:peripheral repeats:NO];
    }
}

/*!
 *   @brief 连接定时器超时，停止连接
 */
- (void)connectTimerRunning:(NSTimer *)timer {
    DLog(@">>>连接设备超时, 已取消连接");
    [self cancelPeripheralConnection:(CBPeripheral *)timer.userInfo];
}


/*!
 *   @brief 断开设备连接
 */
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        if (peripheral.state == CBPeripheralStateConnected || peripheral.state == CBPeripheralStateConnecting) {
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
}

/*!
 *   @brief 断开所有已连接的设备
 */
- (void)cancelAllPeripheralsConnection {
    for (CBPeripheral *peripheral in connectedPeripherals) {
        [self cancelPeripheralConnection:peripheral];
    }
}

/*!
 *   @brief 停止扫描
 */
- (void)cancelScan {
    if (self.centralManager.isScanning) {
        
        [self.centralManager stopScan];
        
        // 扫描计时结束
        if ([self.scanTimer isValid]) {
            [self.scanTimer invalidate];
            self.scanTimer = nil;
            scanTimeLength = 0;
        }
        
        // block回调
        if(self.bridge.callback.blockOnCancelScan) {
            self.bridge.callback.blockOnCancelScan(self.centralManager);
        }
    }
}

/*!
 *   @brief 返回所有搜索到的、已连接的、需要自动连接的设备
 */
- (NSArray *)findAllDiscoverPeripherals {
    return discoverPeripherals;
}
- (NSArray *)findAllConnectedPeripheral {
    return connectedPeripherals;
}

#pragma mark - Privite Method

/*!
 *   @brief 添加扫描到的设备
 */
- (BOOL)addDiscoverdPeripheral:(CBPeripheral *)peripheral {
    
    if (![discoverPeripherals containsObject:peripheral]) {
        [discoverPeripherals addObject:peripheral];
        return YES;
    }
    return NO;
}

/*!
 *   @brief 删除扫描到的设备
 */
- (void)removeAllDiscoverdPeripheral {
    [discoverPeripherals removeAllObjects];
}

/*!
 *   @brief 添加保存已连接的设备
 */
- (void)addConnectPeripheral:(CBPeripheral *)peripheral {
    if (![connectedPeripherals containsObject:peripheral]) {
        [connectedPeripherals addObject:peripheral];
    }
}

/*!
 *   @brief 删除已断开连接的设备
 */
- (void)removeConnectPeripheral:(CBPeripheral *)peripheral {
    if ([connectedPeripherals containsObject:peripheral]) {
        [connectedPeripherals removeObject:peripheral];
    }
}

#pragma mark - 历史记录
- (void)saveToHistoryConnectioned:(CBPeripheral *)peripheral {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self getFromHistoryConnectioned]];
    // 暂时使用唯一标示：名字+UUID
    NSString *identify = [NSString stringWithFormat:@"%@:%@", peripheral.name, peripheral.identifier.UUIDString];
    if (!array) {
        array = [NSMutableArray arrayWithObjects:identify, nil];
    } else if (![array containsObject:identify]) {
        [array addObject:identify];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:array] forKey:@"com.weixhe.hebluetooth.historyConnectPeripherals"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)getFromHistoryConnectioned {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"com.weixhe.hebluetooth.historyConnectPeripherals"];
}

- (BOOL)isContainedInHistory:(CBPeripheral *)peripheral {
    NSArray *history = [self getFromHistoryConnectioned];
    NSString *identify = [NSString stringWithFormat:@"%@:%@", peripheral.name, peripheral.identifier.UUIDString];
    return [history containsObject:identify];
}

- (void)ignorePeripheralFromHistory:(CBPeripheral *)peripheral {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self getFromHistoryConnectioned]];
    NSString *identify = [NSString stringWithFormat:@"%@:%@", peripheral.name, peripheral.identifier.UUIDString];
    if ([array containsObject:identify]) {
        [array removeObject:identify];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"com.weixhe.hebluetooth.historyConnectPeripherals"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_0
- (void)changeBluetoothState:(CBManagerState)state {
    switch (state) {
        case CBManagerStateUnknown:
            _bluetoothState = HEBluetoothStateUnknown;
            DLog(@">>>中心设备-状态未知");
            break;
        case CBManagerStateResetting:
            _bluetoothState = HEBluetoothStateResetting;
            DLog(@">>>中心设备-连接断开 即将重置");
            break;
        case CBManagerStateUnsupported:
            _bluetoothState = HEBluetoothStateUnsupported;
            DLog(@">>>中心设备-该平台不支持蓝牙");
            break;
        case CBManagerStateUnauthorized:
            _bluetoothState = HEBluetoothStateUnauthorized;
            DLog(@">>>中心设备-未授权蓝牙使用");
            break;
        case CBManagerStatePoweredOff:
            _bluetoothState = HEBluetoothStatePoweredOff;
            DLog(@">>>中心设备-蓝牙关闭");
            break;
        case CBManagerStatePoweredOn:
            _bluetoothState = HEBluetoothStatePoweredOn;
            DLog(@">>>中心设备-蓝牙正常开启");
            
            break;
        default:
            break;
    }

}
#else
- (void)changeBluetoothState:(CBCentralManagerState)state {
    switch (state) {
        case CBCentralManagerStateUnknown:
            _bluetoothState = HEBluetoothStateUnknown;
            DLog(@">>>中心设备-状态未知");
            break;
        case CBCentralManagerStateResetting:
            _bluetoothState = HEBluetoothStateResetting;
            DLog(@">>>中心设备-连接断开 即将重置");
            break;
        case CBCentralManagerStateUnsupported:
            _bluetoothState = HEBluetoothStateUnsupported;
            DLog(@">>>中心设备-该平台不支持蓝牙");
            break;
        case CBCentralManagerStateUnauthorized:
            _bluetoothState = HEBluetoothStateUnauthorized;
            DLog(@">>>中心设备-未授权蓝牙使用");
            break;
        case CBCentralManagerStatePoweredOff:
            _bluetoothState = HEBluetoothStatePoweredOff;
            DLog(@">>>中心设备-蓝牙关闭");
            break;
        case CBCentralManagerStatePoweredOn:
            _bluetoothState = HEBluetoothStatePoweredOn;
            DLog(@">>>中心设备-蓝牙正常开启");
            break;
        default:
            break;
    }
}
#endif

#pragma mark - CBCentralManagerDelegate
/*!
 *   @brief 在初始化管理中心完成后，会回调代理中的如下方法，我们必须实现如下方法，
 *          这个方法中可以获取到管理中心的状态
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    // 保存状态
    [self changeBluetoothState:central.state];
    
    // 状态改变callback
    if (self.bridge.callback.blockOnUpdateCentralState) {
        self.bridge.callback.blockOnUpdateCentralState(_bluetoothState);
    }
}

/*!
 *   @brief 中心设备恢复连接，dict中会传入如下键值对：
 *  CBCentralManagerRestoredStatePeripheralsKey    : 恢复连接的外设数组
 *  CBCentralManagerRestoredStateScanServicesKey   : 恢复连接的服务UUID数组
 *  CBCentralManagerRestoredStateScanOptionsKey    : 恢复连接的外设扫描属性字典数组
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

/*!
 *   @brief 扫描的结果, peripheral:扫描到的外设, advertisementData:外设发送的广播数据, RSSI:信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        if ([self addDiscoverdPeripheral:peripheral]) {     // 此处的方法只走一次
            
            // block回调
            if (self.bridge.callback.blockOnDiscoverPeripheral) {
                self.bridge.callback.blockOnDiscoverPeripheral(self.centralManager, peripheral, advertisementData, RSSI);
            }
            
            // 是否自动连接外设
            if ([self isContainedInHistory:peripheral]) {
                [self connectToPeripheral:peripheral];
            }
        }
    }
}

/*!
 *   @brief 连接到Peripherals-成功
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        if ([self.connectTimer isValid]) {
            [self.connectTimer invalidate];
            self.connectTimer = nil;
        }
        
        // 保存已连接的设备
        [self addConnectPeripheral:peripheral];
        
        // 保存历史记录
        if (self.autoReconnectPeripheral) {
            [self saveToHistoryConnectioned:peripheral];
        }
        
        peripheral.delegate = self;
        
        // block回调
        if (self.bridge.callback.blockOnSuccessConnectPeripheral) {
            self.bridge.callback.blockOnSuccessConnectPeripheral(self.centralManager, peripheral);
        }
        
        // 是否自动发现外设服务
        if (self.autoDiscoverServices) {
            [peripheral discoverServices:self.bridge.options.discoverWithServices];     // 根据服务UUID寻找服务对象, 请查看回调方法
        }
    }
}

/*!
 *   @brief 连接到Peripherals-失败
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        // block回调
        if (self.bridge.callback.blockOnFailConnectPeripheral) {
            self.bridge.callback.blockOnFailConnectPeripheral(self.centralManager, peripheral, error);
        }
    }
}

/*!
 *   @brief 断开与外设的连接
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        // block回调
        if (self.bridge.callback.blockOnDisConnectPeripheral) {
            self.bridge.callback.blockOnDisConnectPeripheral(self.centralManager, peripheral, error);
        }
        
        // 判断是否所有的设备都已断开连接
        if ([self findAllConnectedPeripheral].count == 0) {
            // block回调
            if (self.bridge.callback.blockOnAllPeripheralDisconnectioned) {
                self.bridge.callback.blockOnAllPeripheralDisconnectioned(self.centralManager);
            }
        }
        
        // 是否自动连接已断开的外设
        if ([self isContainedInHistory:peripheral]) {
            [self connectToPeripheral:peripheral];
        }
    }
}

#pragma mark - CBPeripheralDelegate

/*!
 *   @brief 外设名称更改时回调的方法
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0) {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnUpdatePeripheralName) {
            self.bridge.callback.blockOnUpdatePeripheralName(peripheral);
        }
    }
}

/*!
 *   @brief 外设服务变化时回调的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(NA, 7_0) {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnModifyPeripheralServices) {
            self.bridge.callback.blockOnModifyPeripheralServices(peripheral, invalidatedServices);
        }
    }
}

/*!
 *   @brief 信号强度改变时调用的方法, ios < 8时会走，基本弃用
 */

#if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0) {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnUpdatePeripheralRSSI) {
            self.bridge.callback.blockOnUpdatePeripheralRSSI(peripheral.RSSI, error);
        }
    }
}

#else
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0) {

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnReadPeripheralRSSI) {
            self.bridge.callback.blockOnReadPeripheralRSSI(RSSI, error);
        }
    }
}
#endif

/*!
 *   @brief 发现服务时调用的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
    if (error) {
        DLog(@">>>外设发现了服务出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnDiscoverServices) {
            self.bridge.callback.blockOnDiscoverServices(peripheral, error);
        }
        
        // 是否自动查找服务中的自服务  ????????
        if (self.autoDiscoverIncludedServices) {
            for (CBService *service in peripheral.services) {
                [peripheral discoverIncludedServices:self.bridge.options.discoverWithServicesIncludedServices forService:service];  // 在服务对象UUID数组中寻找特定服务
            }
        }
        
        // 是否自动查找服务中的特征
        if (self.autoDiscoverCharacteristics) {
            for (CBService *service in peripheral.services) {
                [peripheral discoverCharacteristics:self.bridge.options.discoverWithCharacteristics forService:service];    // 在一个服务中寻找特征值
            }
        }
    }
}

/*!
 *   @brief 在服务中发现子服务回调的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error {

    if (error) {
        DLog(@">>>外设在服务中发现子服务出错： %@\n", error);
    }

    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnDidDiscoverIncludedServicesForService) {
            self.bridge.callback.blockOnDidDiscoverIncludedServicesForService(service, error);
        }
    }
}

/*!
 *   @brief 发现服务的特征值后回调的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设发现服务的特征值出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        // block回调
        if (self.bridge.callback.blockOnDiscoverCharacteristics) {
            self.bridge.callback.blockOnDiscoverCharacteristics(peripheral, service, error);
        }
        
        // 是否需要读取（更新）Characteristic的值
        if (self.autoReadValueForCharacteristic) {
            for (CBCharacteristic *characteristic in service.characteristics) {
               // [peripheral readValueForCharacteristic:characteristic];
              // 判断读写权限
              if (characteristic.properties & CBCharacteristicPropertyRead) {

                  [peripheral readValueForCharacteristic:characteristic];       // 从一个特征中读取数据
              }
            }
        }
        
        // 是否需要寻找 特征 的 描述值
        if (self.autoDiscoverDescriptors) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                [peripheral discoverDescriptorsForCharacteristic:characteristic];       // 寻找特征值的描述
            }
        }
    }
}

/*!
 *   @brief 特征值读取（更新）时回调的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设特征值读取（更新）出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
     
        // block回调
        if (self.bridge.callback.blockOnReadValueForCharacteristic) {
            self.bridge.callback.blockOnReadValueForCharacteristic(peripheral, characteristic, error);
        }
    }
}

/*!
 *   @brief 向特征值写数据时回调的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    if (error) {
        DLog(@">>>外设向特征值写数据出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnWriteValueForCharacteristic) {
            self.bridge.callback.blockOnWriteValueForCharacteristic(peripheral, characteristic, error);
        }
    }
}

/*!
 *   @brief 特征值的通知设置改变时触发的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设特征值的通知设置改变出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnDidUpdateNotificationStateForCharacteristic) {
            self.bridge.callback.blockOnDidUpdateNotificationStateForCharacteristic(peripheral, characteristic, error);
        }
    }
}

/*!
 *   @brief 发现特征值的描述信息触发的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设发现特征值的描述信息出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnDiscoverDescriptorsForCharacteristic) {
            self.bridge.callback.blockOnDiscoverDescriptorsForCharacteristic(peripheral, characteristic, error);
        }

        // 仅读取一次描述值
        if (self.onlyReadOnceValueForDescriptors) {
            for (CBDescriptor *d in characteristic.descriptors) {
                [peripheral readValueForDescriptor:d];
            }
            self.onlyReadOnceValueForDescriptors = NO;
            
        } else if (self.autoReadValueForDescriptors) {
             // 如果需要获取(更新)特征值的描述值
            for (CBDescriptor *d in characteristic.descriptors) {
                [peripheral readValueForDescriptor:d];      // 读取特征的描述值
            }
        }
    }
}

/*!
 *   @brief 特征的描述值更新时触发的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设特征的描述值更新出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnReadValueForDescriptors) {
            self.bridge.callback.blockOnReadValueForDescriptors(peripheral, descriptor, error);
        }
    }
}

/*!
 *   @brief 写描述信息时触发的方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    if (error) {
        DLog(@">>>外设写描述信息出错： %@\n", error);
    }
    
    if ([HEBluetoothUtility filterOnDiscoverPeripheral:peripheral]) {
        
        // block回调
        if (self.bridge.callback.blockOnWriteValueForDescriptors) {
            self.bridge.callback.blockOnWriteValueForDescriptors(peripheral, descriptor, error);
        }
    }
}

@end
