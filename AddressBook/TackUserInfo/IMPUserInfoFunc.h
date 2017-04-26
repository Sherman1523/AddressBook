//
//  IMPDeviceTool.h
//  IMobPay
//
//  Created by Lun.X on 16/8/1.
//  Copyright © 2016年 QTPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "IMPGetAddressBookModel.h"

@interface IMPUserInfoFunc : NSObject

/**
 *  ios 9及以上版本获通讯录
 *
 *  @return Array数据
 */
+ (NSArray *)fetchAddressBookOnIOS9AndLater;

/**
 *  ios 9以下版本获通讯录
 *
 *  @return Array数据
 */
+ (NSArray *)fetchAddressBookBeforeIOS9;
@end
