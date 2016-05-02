//
//  XXFirstViewController.m
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import "XXFirstViewController.h"
#import "XXSecondViewController.h"

@implementation XXFirstViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"第一个控制器";
    self.view.backgroundColor = [UIColor redColor];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"下一个" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtn)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)nextBtn{
    XXSecondViewController * secondViewController = [[XXSecondViewController alloc] init];
    [self.navigationController pushViewController:secondViewController animated:YES];
}

@end
