//
//  HEConnectPeripheralViewController.h
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HEConnectPeripheralViewController : UIViewController

@property (nonatomic, strong) CBPeripheral *peripheral;

@end
