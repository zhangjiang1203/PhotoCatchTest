//
//  ViewController.m
//  PhotoCatchTest
//
//  Created by pg on 2016/11/18.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "ViewController.h"
#import "FCSmallImageViewController.h"


@interface ViewController ()
{
    CGFloat collectionW;
}

@property (strong,nonatomic)NSArray *imageArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取照片胶卷中所对应的信息
    
}
- (IBAction)chooseImageVC {
    
    FCSmallImageViewController *smallVC = [[FCSmallImageViewController alloc]init];
    smallVC.maxSelect = 6;
    [self.navigationController pushViewController:smallVC animated:YES];

    
}



@end
