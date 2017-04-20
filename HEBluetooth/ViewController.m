//
//  ViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEBluetoothDefine.h"

#import "HEBluetooth.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSArray <CBUUID *> *scanForPeripheralsWithServices = nil;   // @[];
    NSDictionary <NSString *, id> *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary <NSString *, id> *connectPeripheralWithOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES};
    NSArray <CBUUID *> *discoverWithServices = nil; // @[];
    NSArray <CBUUID *> *discoverWithCharacteristics = nil;  // @[];
    
    [[HEBluetooth shareBluetooth] setOptionsWithScanForPeripheralsWithServices:scanForPeripheralsWithServices
                                                 scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                                                  connectPeripheralWithOptions:connectPeripheralWithOptions
                                                          discoverWithServices:discoverWithServices
                                                   discoverWithCharacteristics:discoverWithCharacteristics];
    
    [self bluetoothDelegate];
    
    // 1. 第一步：打开蓝牙后扫描周围设备
    [[HEBluetooth shareBluetooth].centralManager scanPeripherals];
    
}

- (void)bluetoothDelegate {
    [[HEBluetooth shareBluetooth] setBlockOnCentralManagerDidUpdateState:^(HEBluetoothState bluetoothState) {
        NSLog(@"0000-中心设备状态修改");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnScanPeripherals:^(CBCentralManager *central, NSInteger timeInsterval, BOOL *stop) {
        NSLog(@"%ld", timeInsterval);
        
        if (timeInsterval == 5) {
            *stop = YES;
        }
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"1111-发现设备");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"2222-连接设备");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"3333-连接设备失败");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"4444-连接设备断开");
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"5555-发现设备的服务");
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDidDiscoverIncludedServicesForService:^(CBService *service, NSError *error) {
        NSLog(@"121212-发现服务中的自服务");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"161616-发现设备的特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"6666-阅读特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidWriteValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"7777-写入特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"8888-发现设备特征的描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"9999-阅读特征的描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidWriteValueForDescriptor:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"101010-写入特征描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"111111-更新特征通知");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"131313-信号强度阅读、更新");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidUpdateName:^(CBPeripheral *peripheral) {
        NSLog(@"141414-设备名称改变");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidModifyServices:^(CBPeripheral *peripheral, NSArray *invalidatedServices) {
        NSLog(@"151515-外设服务变化");
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
