//
//  XXWindow.m
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import "XXWindow.h"
#import <QuartzCore/QuartzCore.h>



// 跟踪视图的大小
#define kTrackViewSize 60
// 跟踪视图中心距屏幕边缘的距离
#define kMargin 43
// 跟踪视图的放大比例
#define kTrackViewScale 1.65
// 跟踪视图右边缘停留距离
#define kTrackViewCenterEdgeRight 43
// 屏幕宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
// 气泡大小
#define kBubbleViewSize 120
// 气泡放大比例
#define kBubbleEdgeRightScale 2.2
// 气泡中心距屏幕最右边的距离
#define kBubbleCenterDistanceX 175
// 颜色
#define kColor(r,g,b,a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a) / 100.0]

// 容器视图上边距
#define kContainnerViewTopMargin 55
// 容器视图左右边距
#define kContainnerViewRAndL 25


@interface XXWindow ()

///  跟随视图
@property (nonatomic, strong) UIImageView * trackView;
///  有些气泡视图
@property (nonatomic, strong) UIView * bubbleView;
///  记录上次的触摸点
@property (nonatomic, assign) CGPoint oldPoint;
///  记录跟随视图开始拖拽是的中心
@property (nonatomic, assign) CGPoint trackViewStartPanCenter;
///  跟踪视图的初始位置
@property (nonatomic, assign) CGRect startPosition;
///  跟随视图在底部的位置
@property (nonatomic, assign) CGPoint bottomPosition;

///  背景蒙版视图
@property (nonatomic, strong) UIView * backCoverView;
///  容器视图
@property (nonatomic, strong) UIView * containerView;

@end

@implementation XXWindow

#pragma mark - 生命周期方法
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setWindow];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setWindow];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    [self bringSubviewToFront:self.bubbleView];

    [self bringSubviewToFront:self.trackView];
}

#pragma mark - 私有方法
- (void)setWindow{
    // 添加视图
    [self addSubview:self.trackView];
    [self addSubview:self.bubbleView];
    
    // 添加边缘手势
    UIScreenEdgePanGestureRecognizer * screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    [screenEdgePan setEdges:UIRectEdgeRight];
    [self addGestureRecognizer:screenEdgePan];
    
}


// 跟踪视图的点击手势
- (void)tapOnTrackView:(UITapGestureRecognizer *)tapOnTrackView{

    CGPoint center = self.trackView.center;
    // 判断跟踪视图的位置，如果不在底部，则移动到底部，如果在底部，则恢复位置
    if (center.x == self.bottomPosition.x && center.y == self.bottomPosition.y) {
        //在底部，则恢复位置
        [self resumeTrackAndCover];
        // 删除中间视图
        [self.backCoverView removeFromSuperview];
        // 移动
        
    }else{
        //不在底部，则移动到底部
        // 记录位置
        self.oldPoint = self.trackView.center;
        
        //添加视图
        [self addSubview:self.backCoverView];
        self.backCoverView.alpha = 0;
        
        // 移动
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:20  options:UIViewAnimationOptionCurveLinear animations:^{
            self.trackView.center = self.bottomPosition;
            self.backCoverView.alpha = 1;
            self.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

// 恢复跟踪视图
- (void)resumeTrackAndCover{
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:20 options:0 animations:^{
        self.trackView.center = self.oldPoint;
        self.backCoverView.alpha = 0;
        self.containerView.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        
        [self.backCoverView removeFromSuperview];
    }];
}

// 边缘拖拽手势方法
- (void)screenEdgePan:(UISwipeGestureRecognizer *)swipe{
    if (self.trackView.center.x > kScreenHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            self.trackView.center = self.trackViewStartPanCenter;
        }];
    }
}

// 拖拽手势方法
- (void)pan:(UIPanGestureRecognizer *)pan{
    // 如果在蒙版底部则不响应拖动手势
    CGPoint center = self.trackView.center;
    if (center.x == self.bottomPosition.x && center.y == self.bottomPosition.y) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {

        self.oldPoint = CGPointMake(0, 0);
        self.trackViewStartPanCenter = self.trackView.center;
        // 放大动画
        [self zoomBig];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        // 移动
        [self trackViewMoveWithPan:pan];
        // 判断右边界
        [self judgeRightBoundaryWithPan:pan];
        // 气泡变化
        [self bubbulChangeWithState:pan.state];
    }else if (pan.state == UIGestureRecognizerStateEnded){
        // 缩小动画
        [self zoomSmall];
        // 判断边界
        [self judgeBoundaryWithPan:pan];
        [self bubbulChangeWithState:pan.state];
    }
}

// 放大动画
- (void)zoomBig{
    [UIView animateWithDuration:0.25 animations:^{
        self.trackView.transform = CGAffineTransformMakeScale(kTrackViewScale,kTrackViewScale);
    }];
}

// 缩小动画
- (void)zoomSmall{
    [UIView animateWithDuration:0.25 animations:^{
        self.trackView.transform = CGAffineTransformIdentity;
    }];
}

// 移动
- (void)trackViewMoveWithPan:(UIPanGestureRecognizer *)pan{
    
    CGPoint currentPoint = [pan translationInView:self];
    CGFloat deltaX = currentPoint.x - self.oldPoint.x;
    CGFloat deltaY = currentPoint.y - self.oldPoint.y;
    CGPoint center = self.trackView.center;
    CGFloat x = center.x + deltaX;
    CGFloat y = center.y + deltaY;
    
    self.trackView.center = CGPointMake(x, y);
    
    self.oldPoint = currentPoint;
}

// 判断边界
- (void)judgeBoundaryWithPan:(UIPanGestureRecognizer *)pan{
    CGPoint center = self.trackView.center;
    // 上下边界
    if (center.y < kMargin) {
        center.y = kMargin;
    }
    if (center.y > kScreenHeight - kMargin) {
        center.y = kScreenHeight - kMargin;
    }
    
    // 左右边界
    if (center.x < kMargin + kScreenWidth * 0.3) {
        center.x = kMargin;
    }else if (center.x > kScreenWidth - kTrackViewCenterEdgeRight){
        center.x += kScreenWidth;
        if (pan.state == UIGestureRecognizerStateChanged) {
            [UIView animateWithDuration:0.25 animations:^{
                self.trackView.center = center;
                self.bubbleView.transform = CGAffineTransformMakeScale(kBubbleEdgeRightScale, kBubbleEdgeRightScale);
                self.bubbleView.alpha = 0.9;
            }];
            
        }else if (pan.state == UIGestureRecognizerStateEnded){
            [UIView animateWithDuration:0.25 animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.bubbleView.alpha = 0;
            } completion:^(BOOL finished) {
                self.bubbleView.alpha = 0.5;
            }];
        }
    }else{
        center.x = kScreenWidth - kTrackViewCenterEdgeRight;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.trackView.center = center;
    }];
}

// 判断右边界
- (void)judgeRightBoundaryWithPan:(UIPanGestureRecognizer *)pan{
    CGPoint center = self.trackView.center;
    if (center.x > kScreenWidth - kTrackViewCenterEdgeRight) {
        center.x += kScreenWidth;
        if (pan.state == UIGestureRecognizerStateChanged) {
            [UIView animateWithDuration:0.25 animations:^{
                self.trackView.center = center;
                self.bubbleView.transform = CGAffineTransformMakeScale(kBubbleEdgeRightScale, kBubbleEdgeRightScale);
                self.bubbleView.alpha = 0.9;
            }];
            
        }else if (pan.state == UIGestureRecognizerStateEnded){
            [UIView animateWithDuration:0.25 animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.bubbleView.alpha = 0;
            } completion:^(BOOL finished) {
                self.bubbleView.alpha = 0.5;
            }];
        }
    }
}

// 气泡变化
- (void)bubbulChangeWithState:(UIGestureRecognizerState)state{
    if (state == UIGestureRecognizerStateChanged) {
        
        // trackView的x中心，超过屏幕一半 bubble放大
        if (self.trackView.center.x > kScreenWidth * 0.5 && self.trackView.center.x < kScreenWidth - kMargin) {
            // 计算放大比例
            CGFloat scale = (self.trackView.center.x - kScreenWidth * 0.25) / kScreenWidth + 1;
            [UIView animateWithDuration:0.1 animations:^{
                self.bubbleView.transform = CGAffineTransformMakeScale(scale, scale);
            }];
            
        }else if (self.trackView.center.x > kScreenWidth - kMargin){
            [UIView animateWithDuration:0.25 animations:^{
                self.bubbleView.transform = CGAffineTransformMakeScale(kBubbleEdgeRightScale, kBubbleEdgeRightScale);
                self.bubbleView.alpha = 0.9;
            }];
        }
        else{// 小于屏幕一半，bubble变回原样
            [UIView animateWithDuration:0.25 animations:^{
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.bubbleView.alpha = 0.5;
            }];
        }
    }else if (state == UIGestureRecognizerStateEnded){
        if (self.trackView.center.x > kScreenWidth * 0.5) {
            [UIView animateWithDuration:0.25 animations:^{
                if (!(self.trackView.center.x > kScreenWidth - kTrackViewCenterEdgeRight)){
                    self.bubbleView.transform = CGAffineTransformScale(self.bubbleView.transform, 1.2, 1.2);
                }
                self.bubbleView.alpha = 0;
            } completion:^(BOOL finished) {
                self.bubbleView.transform = CGAffineTransformIdentity;
                self.bubbleView.alpha = 0.5;
            }];
        }
    }
}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"center"]) {
        CGPoint center = self.bubbleView.center;
        center.y = self.trackView.center.y;
        self.bubbleView.center = center;
    }
}

#pragma mark - set 方法
-(void)setIsHiddenTrackView:(BOOL)isHiddenTrackView{
    _isHiddenTrackView = isHiddenTrackView;
    self.trackView.hidden = isHiddenTrackView;
}

#pragma mark - 懒加载
// 跟踪视图
-(UIImageView *)trackView{
    if (_trackView == nil) {
        _trackView = [[UIImageView alloc] init];
//        _trackView.image = [UIImage imageNamed:@"window_move_button"];
        _trackView.layer.cornerRadius = kTrackViewSize * 0.5;
        _trackView.clipsToBounds = YES;
        _trackView.backgroundColor = [UIColor blueColor];
        _trackView.frame = self.startPosition;
        _trackView.userInteractionEnabled = YES;
        
        // 添加拖拽手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_trackView addGestureRecognizer:pan];
        
        // KVO添加监听
        [_trackView addObserver:self forKeyPath:@"center" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        
        // 添加敲击手势
        UITapGestureRecognizer * tapOnTrackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTrackView:)];
        [_trackView addGestureRecognizer:tapOnTrackView];
        
    }
    return _trackView;
}
// 气泡视图
-(UIView *)bubbleView{
    if (_bubbleView == nil) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.frame = CGRectMake(kScreenWidth, self.trackView.frame.origin.y - (kBubbleViewSize - kTrackViewSize) * 0.5, kBubbleViewSize, kBubbleViewSize);
        _bubbleView.layer.cornerRadius = kBubbleViewSize * 0.5;
        _bubbleView.clipsToBounds = YES;
        _bubbleView.backgroundColor = kColor(246, 121, 102, 100);
        _bubbleView.alpha = 0.5;
    }
    return _bubbleView;
}

// 跟踪视图的开始位置
-(CGRect)startPosition{
    return CGRectMake(kScreenWidth - kTrackViewCenterEdgeRight - kTrackViewSize * 0.5, kScreenHeight - kTrackViewCenterEdgeRight * 2 - kTrackViewSize * 0.5, kTrackViewSize, kTrackViewSize);
}
// 跟踪视图的底部位置
-(CGPoint)bottomPosition{
    _bottomPosition = CGPointMake(kScreenWidth * 0.5,kScreenHeight - 43);
    return _bottomPosition;
}

// 背景蒙版视图
-(UIView *)backCoverView{
    if (_backCoverView == nil) {
        _backCoverView = [[UIView alloc] init];
        _backCoverView.frame = [UIScreen mainScreen].bounds;
        _backCoverView.alpha = 0;
        
        // 添加渐变颜色
        UIColor * startColor = kColor(0, 0, 0, 70);
        UIColor * endColor = kColor(0, 0, 0, 30);
        CAGradientLayer *layer = [CAGradientLayer new];
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        layer.startPoint = CGPointMake(0, 1);
        layer.endPoint = CGPointMake(0, 0);
        layer.frame = _backCoverView.bounds;
        [_backCoverView.layer addSublayer:layer];
        
        // 添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTrackView:)];
        [_backCoverView addGestureRecognizer:tap];
        
        // 添加视图
        [_backCoverView addSubview:self.containerView];
        
    }
    return _backCoverView;
}
// 容器视图
-(UIView *)containerView{
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        // 底层遮挡按钮，防止触摸事件穿透
        UIButton * backButton = [[UIButton alloc] init];
        _containerView.frame = CGRectMake(kContainnerViewRAndL, kContainnerViewTopMargin, kScreenWidth - 2 * kContainnerViewRAndL, self.bottomPosition.y - kTrackViewSize * 0.5 - kContainnerViewTopMargin);
        backButton.frame = _containerView.bounds;
        
        if (self.popViewController != nil) {
            [_containerView addSubview:self.popViewController.view];
            [self.popViewController.view insertSubview:backButton atIndex:0];
        }else{
            [_containerView addSubview:backButton];
        }
        
        _containerView.backgroundColor = kColor(246, 121, 102, 100);
        _containerView.transform = CGAffineTransformMakeScale(0, 0);
        
        _containerView.layer.cornerRadius = 10;
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}


@end