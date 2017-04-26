//
//  IMPDeviceTool.m
//  IMobPay
//
//  Created by Lun.X on 16/8/1.
//  Copyright © 2016年 QTPay. All rights reserved.
//

#import "IMPUserInfoFunc.h"
/** 通讯录数据 */
static NSArray *contactsArr;

@implementation IMPUserInfoFunc

+ (void) initialize{
    contactsArr = [NSArray array];
}

#pragma mark - ios 9 and later
+ (NSArray *)fetchAddressBookOnIOS9AndLater{
    NSArray *dataArray;
    //创建CNContactStore对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //首次访问需用户授权
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        //首次访问通讯录
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        contactsArr = [self fetchContactWithContactStore:contactStore];
    }else {
        //非首次访问通讯录
        contactsArr = [self fetchContactWithContactStore:contactStore];
    }
    if (contactsArr) {
        dataArray = contactsArr;
        NSLog(@"contactsArr == %@",contactsArr);
    }
    return contactsArr;
}

+ (NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
    //判断访问权限
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
        //有权限访问
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactOrganizationNameKey];
        //获取通讯录数组
        NSArray<CNContact*> *arr = [contactStore unifiedContactsMatchingPredicate:nil keysToFetch:keysToFetch error:&error];
        if (!error) {
            NSMutableArray *contacts = [NSMutableArray array];
            for (int i = 0; i < arr.count; i++) {
                IMPGetAddressBookModel *addressBookModel = [[IMPGetAddressBookModel alloc] init];
                CNContact *contact = arr[i];
                //姓名
                NSString *givenName = contact.givenName;
                NSString *familyName = contact.familyName;
                addressBookModel.name = [familyName stringByAppendingString:givenName];
                
                //电话
                NSString *phoneStr = @"";
                for (CNLabeledValue *labelValue in contact.phoneNumbers) {
                    CNPhoneNumber *phoneNumber = labelValue.value;
                    phoneStr = [phoneStr stringByAppendingString:[NSString stringWithFormat:@"%@;",[self stringByReplaceMobilePhone:phoneNumber.stringValue]]];
                }
                addressBookModel.phone = phoneStr;
                
                //公司
                addressBookModel.company = contact.organizationName;
                
                //邮箱
                NSString *emilStr = @"";
                for (CNLabeledValue *labelValue in contact.emailAddresses) {
                    emilStr = [emilStr stringByAppendingString:[NSString stringWithFormat:@"%@;",labelValue.value]];
                }
                addressBookModel.email = emilStr;
                
                //地址
                NSString *postalAddress = @"";
                for (CNLabeledValue *labelValue in contact.postalAddresses) {
                    CNPostalAddress *value = labelValue.value;
                    NSString *address = [NSString stringWithFormat:@"%@%@%@%@",value.country,value.state,value.city,value.street];
                    address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    postalAddress = [postalAddress stringByAppendingString:[NSString stringWithFormat:@"%@;",address]];
                }
                addressBookModel.address = postalAddress;
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     addressBookModel.name,@"contactName",
                                     addressBookModel.phone,@"contactMobile",
                                     addressBookModel.company,@"contactCompany",
                                     addressBookModel.email,@"contaceEmail",
                                     addressBookModel.address,@"contactAddress",
                                     nil];
                
                [contacts addObject:dic];
            }
            return contacts;
        }else {
            NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
            NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
            return contacts;
        }
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
        NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
        return contacts;
    }
}


#pragma mark - before ios 9
+ (NSArray *)fetchAddressBookBeforeIOS9 {
    NSArray *dataArray ;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //首次访问需用户授权
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        //首次访问通讯录
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        contactsArr = [self fetchContactWithAddressBook:addressBook];
    }else{
        //非首次访问通讯录
        contactsArr = [self fetchContactWithAddressBook:addressBook];
    }
    if (addressBook) CFRelease(addressBook);
    if (contactsArr) {
       dataArray  = contactsArr;
    }
    return dataArray;
}

+ (NSMutableArray *)fetchContactWithAddressBook:(ABAddressBookRef)addressBook{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {//有权限访问
        //获取通讯录中的所有人
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        //通讯录中人数
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray *contacts = [NSMutableArray array];
        //循环，获取每个人的个人信息
        //获取电话号码和email
        for (NSInteger i = 0; i < nPeople; i++) {
            IMPGetAddressBookModel *addressBookModel = [[IMPGetAddressBookModel alloc] init];
            //获取个人
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            //获取个人名字
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            CFStringRef abFullName = ABRecordCopyCompositeName(person);
            NSString *nameString = (__bridge NSString *)abName;
            NSString *lastNameString = (__bridge NSString *)abLastName;
            
            if ((__bridge id)abFullName != nil) {
                nameString = (__bridge NSString *)abFullName;
            }else {
                if ((__bridge id)abLastName != nil){
                    nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
                }
            }

            addressBookModel.name = nameString;
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
            if (abName) CFRelease(abName);
            //公司
            CFTypeRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
            addressBookModel.company =(__bridge NSString *)company;
            if (company) CFRelease(company);
            ABPropertyID multiProperties[] = {
                kABPersonPhoneProperty,
                kABPersonEmailProperty,
                kABPersonAddressProperty,
            };
            NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
            
            //获取手机号、email、地址
            NSString *phoneStr = @"";
            NSString *emailStr = @"";
            NSString *postalAddress = @"";
            
            for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                ABPropertyID property = multiProperties[j];
                ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                NSInteger valuesCount = 0;
                if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                
                if (valuesCount == 0) {
                    if (valuesRef) CFRelease(valuesRef);
                    continue;
                }
                
                for (NSInteger k = 0; k < valuesCount; k++) {
                    CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                    switch (j) {
                        case 0: {
                            //phoneNumber
                            phoneStr = [phoneStr stringByAppendingString:[NSString stringWithFormat:@"%@;",[self stringByReplaceMobilePhone:(__bridge NSString*)value]]];
                            break;
                        }case 1: {
                            //e-mail
                            emailStr = [emailStr stringByAppendingString:[NSString stringWithFormat:@"%@;",(__bridge NSString*)value]];
                            break;
                        }case 2: {
                            //address
                            NSDictionary *valueDic = (__bridge NSDictionary *)value;
                            NSString *country = [valueDic objectForKey:@"Country"];
                            NSString *state = [valueDic objectForKey:@"State"];
                            NSString *city = [valueDic objectForKey:@"City"];
                            NSString *street = [[valueDic objectForKey:@"Street"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            NSString *address = [NSString stringWithFormat:@"%@%@%@%@",country,state,city,street];
                            postalAddress = [postalAddress stringByAppendingString:[NSString stringWithFormat:@"%@;",address]];
                            break;
                        }
                    }
                    if (value) CFRelease(value);
                }
                if (valuesRef) CFRelease(valuesRef);
            }
            addressBookModel.phone = phoneStr;
            addressBookModel.email = emailStr;
            addressBookModel.address = postalAddress;
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 addressBookModel.name,@"contactName",
                                 addressBookModel.phone,@"contactMobile",
                                 addressBookModel.company,@"contactCompany",
                                 addressBookModel.email,@"contaceEmail",
                                 addressBookModel.address,@"contactAddress",
                                 nil];
            [contacts addObject:dic];
        }
        if (allPeople) CFRelease(allPeople);
        return contacts;
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
        NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
        return contacts;
    }
}



+ (NSString *)stringByReplaceMobilePhone:(NSString *)mobileNo
{
    mobileNo = [[[[[[[[[[[mobileNo stringByReplacingOccurrencesOfString:@"(" withString:@""]
                         stringByReplacingOccurrencesOfString:@")" withString:@""]
                        stringByReplacingOccurrencesOfString:@" " withString:@""]
                       stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"+86" withString:@""] stringByReplacingOccurrencesOfString:@"17951" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"*86" withString:@""]
                 stringByReplacingOccurrencesOfString:@"*" withString:@""]
                stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    return mobileNo;
}
@end
