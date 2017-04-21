//
//  HECharacteristicViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/21.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "HECharacteristicViewController.h"
#import "HEBluetooth.h"

@interface HECharacteristicViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HECharacteristicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100)];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
    [self.currPeripheral readValueForCharacteristic:self.characteristic];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = [NSString stringWithFormat:@"蓝牙名称:%@ \n 服务UUID:%@, \n%@", self.currPeripheral.name, self.characteristic.UUID, self.characteristic.UUID.UUIDString];
    
    CGRect frame = self.titleLabel.frame;
    frame.size.height = [self labelHight];
    self.titleLabel.frame = frame;
    
    self.tableView.tableHeaderView = self.titleLabel;
    
    
}

- (CGFloat)labelHight {
    
    CGRect rect = [self.titleLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil];
    return rect.size.height;
    
}


- (void)setDelegate {
    
    [[HEBluetooth shareBluetooth] setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"%@", characteristic);
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


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    return cell;
}

@end
