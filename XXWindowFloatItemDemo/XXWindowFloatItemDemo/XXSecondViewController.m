//
//  XXSecondViewController.m
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import "XXSecondViewController.h"
#import "XXWindow.h"

@implementation XXSecondViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"第二个控制器";
    self.view.backgroundColor = [UIColor greenColor];
    
    UIButton * hideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [hideBtn setTitle:@"隐藏" forState:UIControlStateNormal];
    hideBtn.backgroundColor = [UIColor grayColor];
    hideBtn.center = self.view.center;
    [hideBtn addTarget:self action:@selector(hideBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideBtn];
}

- (void)hideBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([sender.titleLabel.text isEqualToString:@"隐藏"]) {
        [sender setTitle:@"显示" forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"隐藏" forState:UIControlStateNormal];
    }
    if ([[UIApplication sharedApplication].keyWindow isKindOfClass:[XXWindow class]]) {
        XXWindow * window = (XXWindow *)[UIApplication sharedApplication].keyWindow;
        window.isHiddenTrackView = sender.selected;
    }
}

@end
