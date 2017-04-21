//
//  HEConnectPeripheralViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEConnectPeripheralViewController.h"
#import "HEBluetooth.h"

@interface HEConnectPeripheralViewController ()

@end

@implementation HEConnectPeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDelegate {
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

@end
