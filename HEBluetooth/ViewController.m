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
#import "HEConnectPeripheralViewController.h"

#import "HEBluetooth.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *peripheralDataArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    peripheralDataArray = [[NSMutableArray alloc]init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    

    
    NSArray <CBUUID *> *scanForPeripheralsWithServices = nil;   // @[];
    NSDictionary <NSString *, id> *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary <NSString *, id> *connectPeripheralWithOptions = nil; //@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES};
    NSArray <CBUUID *> *discoverWithServices = nil; // @[];
    NSArray <CBUUID *> *discoverWithCharacteristics = nil;  // @[];
    
    [self bluetoothDelegate];
    [[HEBluetooth shareBluetooth] setOptionsWithScanForPeripheralsWithServices:scanForPeripheralsWithServices
                                                 scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                                                  connectPeripheralWithOptions:connectPeripheralWithOptions
                                                          discoverWithServices:discoverWithServices
                                                   discoverWithCharacteristics:discoverWithCharacteristics];
    
    
    // 1. 第一步：打开蓝牙后扫描周围设备
    [[HEBluetooth shareBluetooth] scanPeripherals];
    
}

- (void)bluetoothDelegate {
    __weak typeof(self) weakSelf = self;
    
    [[HEBluetooth shareBluetooth] setBlockOnCentralManagerDidUpdateState:^(HEBluetoothState bluetoothState) {
        NSLog(@"0000-中心设备状态修改");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnScanPeripherals:^(CBCentralManager *central, NSInteger timeInsterval, BOOL *stop) {
        NSLog(@"%ld", timeInsterval);
        
        if (timeInsterval == 60) {
            *stop = YES;
        }
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnCancelScan:^(CBCentralManager *centralManager) {
        NSLog(@"结束扫描");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"1111-发现设备");
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"2222-连接设备");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            HEConnectPeripheralViewController *vc = [[HEConnectPeripheralViewController alloc] init];
            vc.peripheral = peripheral;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"3333-连接设备失败");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"4444-连接设备断开");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
    
    if(![peripherals containsObject:peripheral]) {
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [peripheralDataArray addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return peripheralDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
    NSNumber *RSSI = [item objectForKey:@"RSSI"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *peripheralName;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        
        peripheralName = peripheral.name;
        
    }else{
        peripheralName = [peripheral.identifier UUIDString];
    }
    
    cell.textLabel.text = peripheralName;
    //信号和服务
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[HEBluetooth shareBluetooth] cancelScan];
    
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
//    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
//    NSNumber *RSSI = [item objectForKey:@"RSSI"];
 
    [[HEBluetooth shareBluetooth] connectPeripheral:peripheral];
}

@end
