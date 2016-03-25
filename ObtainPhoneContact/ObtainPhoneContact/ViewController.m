//
//  ViewController.m
//  ObtainPhoneContact
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 ZhangFan. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self obtainPhoneAllContact];
}

#pragma mark - 获取手机所有联系人
- (void)obtainPhoneAllContact
{
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int   __block tip=0;
    //声明一个通讯簿的引用
    ABAddressBookRef addBook =nil;
    //因为在IOS6.0之后和之前的权限申请方式有所差别，这里做个判断
    if   ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        //创建通讯簿的引用
        addBook=ABAddressBookCreateWithOptions(NULL, NULL);
        //创建一个出事信号量为0的信号
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        //申请访问权限
        ABAddressBookRequestAccessWithCompletion(addBook, ^( bool   greanted, CFErrorRef error)        {
            //greanted为YES是表示用户允许，否则为不允许
            if   (!greanted) {
                tip=1;
            }
            //发送一次信号
            dispatch_semaphore_signal(sema);
        });
        //等待信号触发
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        //IOS6之前
        addBook =ABAddressBookCreate();
    }
    if   (tip) {
        //做一个友好的提示
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@ "温馨提示"   message:@ "请您设置允许APP访问您的通讯录\nSettings>General>Privacy"   delegate:self cancelButtonTitle:@ "确定"   otherButtonTitles:nil, nil];
        [alart show];
        return ;
    }
    
    //获取所有联系人的数组
    CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
    //获取联系人总数
    CFIndex number = ABAddressBookGetPersonCount(addBook);
    //进行遍历
    for   (NSInteger i=0; i<number; i++) {
        //获取联系人对象的引用
        ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
        //获取当前联系人名字
        NSString*firstName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        //获取当前联系人姓氏
        NSString*lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
        
        //获取当前联系人的公司
        NSString*organization=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonOrganizationProperty));
        //获取当前联系人的职位
        NSString*job=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonJobTitleProperty));
        //获取当前联系人的部门
        NSString*department=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonDepartmentProperty));
        //获取当前联系人的电话 数组
        NSMutableArray * phoneArr = [[NSMutableArray alloc]init];
        ABMultiValueRef phones= ABRecordCopyValue(people, kABPersonPhoneProperty);
        for   (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
            [phoneArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j))];
        }
        
        //获取当前联系人头像图片
        NSData*userImage=(__bridge NSData*)(ABPersonCopyImageData(people));
        
        if (lastName == NULL) {
            NSLog(@"姓名：%@",firstName);
        }
        else if (firstName == NULL)
        {
            NSLog(@"姓名：%@",lastName);
        }
        else if(firstName != NULL && lastName != NULL){
            NSLog(@"姓名：%@%@",lastName,firstName);
        }
        NSString *str = phoneArr;
        NSLog(@"联系电话:%@",phoneArr);
        
        if (userImage == NULL) {
            NSLog(@"头像为空");
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
