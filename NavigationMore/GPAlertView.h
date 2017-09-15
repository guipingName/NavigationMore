//
//  GPMoreView.h
//  NavigationMore
//
//  Created by guiping on 2017/9/15.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GPHeaderviewLocation) {
    GPHeaderviewLocationLeft,     // 箭头在左边
    GPHeaderviewLocationCenter,   // 箭头在右边
    GPHeaderviewLocationRight,    // 箭头在中间
};

@class GPAlertView;
@protocol GPAlertViewDelegate <NSObject>
@optional
- (void)didSlectedItemWithTitle:(NSString *)title;
@end

@interface GPAlertView : UIButton

@property (nonatomic, weak) id <GPAlertViewDelegate> target;
@property (nonatomic, strong) UIColor *textColor;       // 文字颜色 Default whiteColor
@property (nonatomic, strong) UIColor *lineColor;       // 线条颜色 Default whiteColor
@property (nonatomic, strong) UIFont *titleFont;        // 文字大小 Default 17
@property (nonatomic, assign) CGFloat contentViewWidth; // 显示内容的宽度（导航） Default 178
@property (nonatomic, assign) CGFloat tbCellHeight;     // 单元格高度 Default 60
@property (nonatomic, assign) GPHeaderviewLocation headerViewAlignment; // 三角形的位置（左中右）
@property (nonatomic, assign) CGRect imgFrame;      // 图片的frame
@property (nonatomic, assign) CGRect lbTitleFrame;  // 标签的frame
@property (nonatomic, assign) NSUInteger cellNumbersMax;    // 设置显示cell的个数，当大于该设定值，tb可以滚动 默认超过3个时tb可以滚动

// 导航栏提示框（有图
-(instancetype)initWithItemRect:(CGRect)itemRect titleArray:(NSArray *)titleArray imageNameArray:(NSArray *)imageNameArray;

// 导航栏提示框（无图）
- (instancetype) initWithItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray;

// 显示
- (void) showInViewController:(UIViewController *) viewController;

// 事件处理
- (void) didSelectItemWithTitleCallBack:(void(^)(NSString *title))callBack;
@end







@interface BgView : UIView

@end
