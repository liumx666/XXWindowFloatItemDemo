//
//  XXPopViewController.m
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import "XXPopViewController.h"

@implementation XXPopViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    UIButton * centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    centerBtn.center = self.view.center;
    [centerBtn setTitle:@"点我啊" forState:UIControlStateNormal];
    [centerBtn addTarget:self action:@selector(centerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    centerBtn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:centerBtn];
}

- (void)centerBtnClicked:(UIButton *)sender {
    NSLog(@"%s",__FUNCTION__);
}

@end
