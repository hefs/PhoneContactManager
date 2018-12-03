//
//  ViewController.m
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/3.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import "ViewController.h"
#import "PhoneContactsManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)didCheckContact:(UIButton *)sender {
    [[PhoneContactsManager shareManager] contactCheckedWithTarget:self handler:^(PhoneContact * _Nonnull contact) {
        NSLog(@"%@",contact.description);
    }];
}



@end
