//
//  ViewController.m
//  直播test
//
//  Created by Zeus on 2017/7/21.
//  Copyright © 2017年 Zeus. All rights reserved.
//

#import "ViewController.h"
#import "PLPlayerViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma mark --- 开始播放按钮 ---
- (IBAction)startPlayAction:(id)sender {
    
    PLPlayerViewController *playVC = [[PLPlayerViewController alloc]init];
    UINavigationController *playNav = [[UINavigationController alloc]initWithRootViewController:playVC];
    [self presentViewController:playNav animated:NO completion:nil];
}
















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
