//
//  PhoneContactsManager.m
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/3.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import "PhoneContactsManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#ifdef NSFoundationVersionNumber_iOS_8_x_Max
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#endif

@implementation PhoneContact

@end

@interface PhoneContactsManager ()<CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, copy) void(^ContactSelectHandler)(PhoneContact *contact) ;
@end

PhoneContactsManager *manager = nil;
@implementation PhoneContactsManager
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#ifdef NSFoundationVersionNumber_iOS_8_x_Max
- (void)contactCheckedWithTarget:(UIViewController *)target handler:(void (^)(PhoneContact * _Nonnull))handler{
    _ContactSelectHandler = handler;
    [self checkAddressBookAuthorization:^(BOOL isAuthorized) {
        if(@available(iOS 9.0, *)){
            if (isAuthorized) {
                CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
                contactPicker.delegate = self;
                contactPicker.displayedPropertyKeys = @[CNContactGivenNameKey,CNContactFamilyNameKey, CNContactPhoneNumbersKey];
                [target presentViewController:contactPicker animated:YES completion:nil];
            }
        }
    }];
}

- (void)checkContactAuthorization:(void (^)(BOOL isAuthorized))block{
    if(@available(iOS 9.0, *)){
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error){
                    NSLog(@"Error: %@", error);
                }else if (!granted){
                    block(NO);
                }else{
                    block(YES);
                }
            }];
        }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            block(YES);
        }else {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
        }
    }
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty API_AVAILABLE(ios(9.0)){
    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
    NSString *name = [CNContactFormatter stringFromContact:contactProperty.contact style:CNContactFormatterStyleFullName];
    if(_ContactSelectHandler){
        PhoneContact *people = [PhoneContact new];
        people.contactName = name;
        people.contactPhoneNumber = phoneNumber.stringValue;
        _ContactSelectHandler(people);
    }
}
#endif

- (void)peopleCheckedWithTarget:(UIViewController *)target handler:(void (^)(PhoneContact * _Nonnull))handler{
    _ContactSelectHandler = handler;
    [self checkAddressBookAuthorization:^(BOOL isAuthorized) {
        if (isAuthorized) {
            ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
            peoplePicker.peoplePickerDelegate = self;
            [target presentViewController:peoplePicker animated:YES completion:nil];
        }
    }];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    if(_ContactSelectHandler){
        PhoneContact *people = [PhoneContact new];
        people.contactName = (__bridge NSString * _Nonnull)(anFullName);
        people.contactPhoneNumber = (__bridge NSString * _Nonnull)(value);
        _ContactSelectHandler(people);
    }
}

- (void)checkAddressBookAuthorization:(void (^)(BOOL isAuthorized))block {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus == kABAuthorizationStatusNotDetermined){
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    NSLog(@"Error: %@", (__bridge NSError *)error);
                }else if (!granted){
                    block(NO);
                }else{
                    block(YES);
                }
            });
        });
    }else if (authStatus == kABAuthorizationStatusAuthorized){
        block(YES);
    }else {
        NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
    }
}

@end
