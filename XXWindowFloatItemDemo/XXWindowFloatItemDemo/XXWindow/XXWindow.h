//
//  XXWindow.h
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XXWindow : UIWindow

///  容器视图中要放置的视图的控制器
@property (nonatomic, strong) UIViewController * popViewController;

///  是否隐藏跟踪视图
@property (nonatomic, assign) BOOL isHiddenTrackView;

@end

