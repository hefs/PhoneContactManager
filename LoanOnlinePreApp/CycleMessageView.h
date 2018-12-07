//
//  CycleMessageView.h
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/6.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleMessageView : UIView
@property (nonatomic) NSArray<NSString *> *messages;
@property (nonatomic, copy) void(^CycleMessageClickedHandler)(NSInteger index,NSString *message) ;
@end
