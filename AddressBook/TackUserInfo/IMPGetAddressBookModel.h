//
//  IMPGetAddressBookModel.h
//  IMobPay
//
//  Created by Lun.X on 16/8/1.
//  Copyright © 2016年 QTPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMPGetAddressBookModel : NSObject
/** 姓名 */
@property (nullable, nonatomic, retain) NSString *name;
/** 电话 */
@property (nullable, nonatomic, retain) NSString *phone;
/** 地址 */
@property (nullable, nonatomic, retain) NSString *address;
/** 邮箱 */
@property (nullable, nonatomic, retain) NSString *email;
/** 工作单位 */
@property (nullable, nonatomic, retain) NSString *company;

@end
