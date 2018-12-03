//
//  PhoneContactsManager.h
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/3.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface PhoneContact : NSObject
@property (nonatomic, copy) NSString *contactPhoneNumber;
@property (nonatomic, copy) NSString *contactName;
@end

@interface PhoneContactsManager : NSObject
+ (instancetype)shareManager;
#ifdef NSFoundationVersionNumber_iOS_9_0
- (void)contactCheckedWithTarget:(nonnull UIViewController *)target handler:(void(^)(PhoneContact *contact))handler;
#endif
- (void)peopleCheckedWithTarget:(nonnull UIViewController *)target handler:(void(^)(PhoneContact *contact))handler;
@end


NS_ASSUME_NONNULL_END
