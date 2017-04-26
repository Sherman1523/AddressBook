//
//  ViewController.m
//  AddressBook
//
//  Created by Lun.X on 2017/4/26.
//  Copyright © 2017年 Lun.X. All rights reserved.
//

#import "ViewController.h"
#import "IMPUserInfoFunc.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
    };
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createGetBtn];
}

- (void)createGetBtn
{
    UIButton *getBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [getBtn setFrame:CGRectMake(self.view.frame.size.width-80, 20,60 , 30)];
    [getBtn setTitle:@"获取" forState:UIControlStateNormal];
    [getBtn setBackgroundColor:[UIColor blackColor]];
    [getBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getBtn addTarget:self action:@selector(getButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [getBtn.layer setMasksToBounds:YES];
    [getBtn.layer setCornerRadius:2.0];
    [self.view addSubview:getBtn];
}


/**
 获取到通讯录信息
 */
- (void)getButtonClick:(id)sender
{
    if ([self getSystemVersion].floatValue >= 9.0) {
        self.dataArray = [IMPUserInfoFunc fetchAddressBookOnIOS9AndLater];
    } else {
        self.dataArray = [IMPUserInfoFunc fetchAddressBookBeforeIOS9];
    }
    
}


/**
 *  手机系统版本
 *
 *  @return e.g. ios 9.3.1
 */
- (NSString *)getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
