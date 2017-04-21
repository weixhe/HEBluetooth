//
//  HEConnectPeripheralViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HEConnectPeripheralViewController.h"
#import "HEBluetooth.h"
#import "HEPeripheralModel.h"
#import "HECharacteristicViewController.h"

@interface HEConnectPeripheralViewController ()
{
    CBPeripheral *currentPeripheral;
}
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation HEConnectPeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setDelegate];
    
    // 检测、发现服务
    [self.peripheral discoverServices:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDelegate {
     __weak typeof(self)weakSelf = self;
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"5555-发现设备的服务");
        currentPeripheral = peripheral;
        for (CBService *s in peripheral.services) {
            [self testServices:s];
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDidDiscoverIncludedServicesForService:^(CBService *service, NSError *error) {
        NSLog(@"121212-发现服务中的自服务");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"161616-发现设备的特征");
        [weakSelf testCharacteristicForService:service];
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

// 整理数据
- (void)testServices:(CBService *)service {
    HEPeripheralModel *model = [[HEPeripheralModel alloc] init];
    [model setServiceUUID:service.UUID];
    [self.dataSource addObject:model];
    
    // 插入一个session
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.dataSource.count - 1];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)testCharacteristicForService:(CBService *)service {
 
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (int i = 0; i < self.dataSource.count; i++) {
        HEPeripheralModel *model = [self.dataSource objectAtIndex:i];
        if ([model.serviceUUID isEqual:service.UUID]) {
            model.characteristics = service.characteristics;
            
            
            // 计算indexPath
            for (int j = 0; j < model.characteristics.count; j++) {
                NSInteger section = i;
                NSInteger row = j;
                
                // 插入service对应的sell
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [indexPaths addObject:indexPath];
            }
            break;
        }
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark -Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HEPeripheralModel *model = [self.dataSource objectAtIndex:section];
    return [model.characteristics count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBCharacteristic *characteristic = [[[self.dataSource objectAtIndex:indexPath.section] characteristics] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"characteristicCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"characteristicCell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", characteristic.UUID];
    cell.detailTextLabel.text = characteristic.description;
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    HEPeripheralModel *model = [self.dataSource objectAtIndex:section];
    title.text = [NSString stringWithFormat:@"%@", model.serviceUUID];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor darkGrayColor]];
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    HEPeripheralModel *model = [self.dataSource objectAtIndex:indexPath.section];

    
    HECharacteristicViewController *vc = [[HECharacteristicViewController alloc]init];
    vc.currPeripheral = currentPeripheral;
    vc.serviceUUID = model.serviceUUID;
    vc.characteristic = [model.characteristics objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
