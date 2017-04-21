//
//  HECharacteristicViewController.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HECharacteristicViewController : UIViewController

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) CBPeripheral *currPeripheral;
@property (nonatomic, copy) CBUUID *serviceUUID;
@property (nonatomic,strong) CBCharacteristic *characteristic;

@property (nonatomic, strong) NSMutableArray *dataSource;


@end
