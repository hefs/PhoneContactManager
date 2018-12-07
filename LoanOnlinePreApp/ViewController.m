//
//  ViewController.m
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/3.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import "ViewController.h"
#import "PhoneContactsManager.h"
#import "CycleMessageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CycleMessageView *cycleView = [[CycleMessageView alloc] initWithFrame:CGRectMake(20, 80, CGRectGetWidth(self.view.frame) - 40, 40)];
    cycleView.messages = @[@"温柔第三方曲蔚然体育",@"阿斯顿法国红酒",@"自行车v把你们",@"破iu也挺热玩"];
    cycleView.CycleMessageClickedHandler = ^(NSInteger index, NSString *message) {
        NSLog(@"index:%ld,message:%@",(long)index,message);
    };
    //    cycleView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:cycleView];
}
- (IBAction)didCheckContact:(UIButton *)sender {
    [[PhoneContactsManager shareManager] contactCheckedWithTarget:self handler:^(PhoneContact * _Nonnull contact) {
        NSLog(@"%@",contact.description);
    }];
}



@end
