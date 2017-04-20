//
//  HEPeripheralManager.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/20.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEPeripheralManager.h"

@interface HEPeripheralManager ()
{
    int PERIPHERAL_MANAGER_INIT_WAIT_TIMES;
    int didAddServices;     // 添加了服务的个数
    NSTimer *addServiceTimer;
}

@end

@implementation HEPeripheralManager

@synthesize peripheralManager = _peripheralManager, localName = _localName;
@synthesize bridge = _bridge, services = _services, advertisementData = _advertisementData;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _localName = @"heperipheral-default-name";
        
    }
    return self;
}

#pragma mark - Accessors

- (CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return _peripheralManager;
}

#pragma mark - Method

/*!
 *   @brief 添加一些服务，参数：数组, 同时启动广播
 */
- (void)addServices:(NSArray *)services {
    if (self.bluetoothState != HEBluetoothStatePoweredOn) {
        _services = [NSMutableArray arrayWithArray:services];
        for (CBMutableService *s in self.services) {
            [_peripheralManager addService:s];
        }
    } else {
        
        // 如果蓝牙没有打开，3s后再次重试
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self addServices:self.services];
        });
    }
}

/*!
 *  @brief 删除某一个服务
 */
- (void)removeServices:(CBMutableService *)service {
    if ([self.services containsObject:service]) {
        didAddServices--;
        [self.peripheralManager removeService:service];        
    }
}

/*!
 *   @brief 删除所有的服务
 */
- (void)removeAllServices {
    if (self.services.count != 0) {
        didAddServices = 0;
        [self.peripheralManager removeAllServices];
    }
}

/*!
 *   @brief 添加一个广播包，连接到设备时可以读取到
 */
- (void)addManufacturerData:(NSData *)data {
    _advertisementData = data;
}

/*!
 *  @brief 启动广播
 */
- (void)startAdvertising {
    
    if (self.peripheralManager.isAdvertising) {
        DLog(@">>>正在广播中，无需再次开启");
        return;
    }
    
    // 蓝牙打开，并且添加的服务数一致，则开启广播
    if (self.bluetoothState == HEBluetoothStatePoweredOn && self.services.count == didAddServices) {
        
        PERIPHERAL_MANAGER_INIT_WAIT_TIMES = 0;
        NSMutableArray *UUIDS = [NSMutableArray array];
        for (CBMutableService *s in self.services) {
            [UUIDS addObject:s.UUID];
        }
        
        // 启动广播
        if (self.advertisementData) {
            [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:UUIDS,
                                                       CBAdvertisementDataLocalNameKey:self.localName,
                                                       CBAdvertisementDataManufacturerDataKey:self.advertisementData}];
        } else {
            [self.peripheralManager startAdvertising: @{CBAdvertisementDataServiceUUIDsKey:UUIDS, CBAdvertisementDataLocalNameKey:self.localName}];
        }
        return;
    } else {
        
        // 无法开启广播，可能是蓝牙未开，或者还没有接收到服务，3s后再次尝试，默认有5次机会开启广播
        PERIPHERAL_MANAGER_INIT_WAIT_TIMES++;
        if (PERIPHERAL_MANAGER_INIT_WAIT_TIMES > 5) {
            DLog(@">>>error： 第%d次等待peripheralManager打开任然失败，请检查蓝牙设备是否可用", PERIPHERAL_MANAGER_INIT_WAIT_TIMES);
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startAdvertising];
        });
        DLog(@">>> 第%d次等待peripheralManager打开", PERIPHERAL_MANAGER_INIT_WAIT_TIMES);
    }

}

/*!
 *   @brief 停止广播
 */
- (void)stopAdvertising {
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - CBPeripheralManagerDelegate

/*!
 *   @brief 这个方法是必须实现的 状态可用后可以发送广播
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
    
    switch (peripheral.state) {
        case CBManagerStateUnknown:
            _bluetoothState = HEBluetoothStateUnknown;
            DLog(@">>>外设管理中心-状态未知");
            break;
        case CBManagerStateResetting:
            _bluetoothState = HEBluetoothStateResetting;
            DLog(@">>>外设管理中心-连接断开 即将重置");
            break;
        case CBManagerStateUnsupported:
            _bluetoothState = HEBluetoothStateUnsupported;
            DLog(@">>>外设管理中心-该平台不支持蓝牙");
            break;
        case CBManagerStateUnauthorized:
            _bluetoothState = HEBluetoothStateUnauthorized;
            DLog(@">>>外设管理中心-未授权蓝牙使用");
            break;
        case CBManagerStatePoweredOff:
            _bluetoothState = HEBluetoothStatePoweredOff;
            DLog(@">>>外设管理中心-蓝牙关闭");
            break;
        case CBManagerStatePoweredOn:
            _bluetoothState = HEBluetoothStatePoweredOn;
            DLog(@">>>外设管理中心-蓝牙正常开启");
            
            break;
        default:
            break;
    }
#else
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            _bluetoothState = HEBluetoothStateUnknown;
            DLog(@">>>外设管理中心-状态未知");
            break;
        case CBPeripheralManagerStateResetting:
            _bluetoothState = HEBluetoothStateResetting;
            DLog(@">>>外设管理中心-连接断开 即将重置");
            break;
        case CBPeripheralManagerStateUnsupported:
            _bluetoothState = HEBluetoothStateUnsupported;
            DLog(@">>>外设管理中心-该平台不支持蓝牙");
            break;
        case CBPeripheralManagerStateUnauthorized:
            _bluetoothState = HEBluetoothStateUnauthorized;
            DLog(@">>>外设管理中心-未授权蓝牙使用");
            break;
        case CBPeripheralManagerStatePoweredOff:
            _bluetoothState = HEBluetoothStatePoweredOff;
            DLog(@">>>外设管理中心-蓝牙关闭");
            break;
        case CBPeripheralManagerStatePoweredOn:
            _bluetoothState = HEBluetoothStatePoweredOn;
            DLog(@">>>外设管理中心-蓝牙正常开启");
            break;
        default:
            break;
    }
#endif


}

/*!
 *   @brief 连接回复时调用的方法 和centralManager类似
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

/*!
 *   @brief 开始发送广播时调用的方法
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    
}

/*!
 *   @brief 添加服务调用的回调
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error {
    
}

/*!
 *   @brief 当一个central设备订阅一个特征值时调用的方法
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
}

/*!
 *   @brief 取消订阅一个特征值时调用的方法
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    
}

/*!
 *   @brief 收到读请求时触发的方法
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
}

/*!
 *   @brief 收到写请求时触发的方法
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
}

/*!
 *   @brief 外设准备更新特征值时调用的方法
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    
}



@end

/*!
 *   @brief 生成一个服务的特征，包含了数据data和只读（只写、通知、读写）性，特征中又包含了一个描述值
 */
void makeCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *properties, NSString *descriptor) {
    
    // paramter for properties
    CBCharacteristicProperties prop = 0x00;
    if ([properties containsString:@"r"]) {
        prop =  prop | CBCharacteristicPropertyRead;
    }
    if ([properties containsString:@"w"]) {
        prop =  prop | CBCharacteristicPropertyWrite;
    }
    if ([properties containsString:@"n"]) {
        prop =  prop | CBCharacteristicPropertyNotify;
    }
    if (properties == nil || [properties isEqualToString:@""]) {
        prop = CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite;
    }
    
    CBMutableCharacteristic *c = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:UUID] properties:prop  value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    // paramter for descriptor
    if (!(descriptor == nil || [descriptor isEqualToString:@""])) {
        // c设置description对应的haracteristics字段描述
        CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
        CBMutableDescriptor *desc = [[CBMutableDescriptor alloc] initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:descriptor];
        [c setDescriptors:@[desc]];
    }
    
    if (!service.characteristics) {
        service.characteristics = @[];
    }
    NSMutableArray *cs = [service.characteristics mutableCopy];
    [cs addObject:c];
    service.characteristics = [cs copy];
}

/*!
 *   @brief 构造一个包含初始值的Characteristic，并加入service,包含了初值的characteristic必须设置permissions和properties都为只读
 */
void makeStaticCharacteristicToService(CBMutableService *service, NSString *UUID, NSString *descriptor, NSData *data) {
    
    CBMutableCharacteristic *c = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:UUID] properties:CBCharacteristicPropertyRead  value:data permissions:CBAttributePermissionsReadable];
    
    // paramter for descriptor
    if (!(descriptor == nil || [descriptor isEqualToString:@""])) {
        // c设置description对应的haracteristics字段描述
        CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
        CBMutableDescriptor *desc = [[CBMutableDescriptor alloc] initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:descriptor];
        [c setDescriptors:@[desc]];
    }
    
    if (!service.characteristics) {
        service.characteristics = @[];
    }
    NSMutableArray *cs = [service.characteristics mutableCopy];
    [cs addObject:c];
    service.characteristics = [cs copy];
}


/*!
 *   @brief 根据UUID生成一个服务
 */
CBMutableService *makeCBService(NSString *UUID) {
    
    CBMutableService *s = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:UUID] primary:YES];
    return s;
}

/*!
 *   @brief 生成一个UUID
 */
NSString *genUUID() {
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}
