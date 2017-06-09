//
//  ViewController.m
//  MYDownload
//
//  Created by ifly on 2017/6/7.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "ViewController.h"
#import "MYCommonHelper.h"

@interface ViewController ()

@end



@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%f",[MYCommonHelper getFileSizeNumber:@"12M239K33B"]);
    NSLog(@"%d",12 * 1024 * 1024 + 239 * 1024 + 33);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
