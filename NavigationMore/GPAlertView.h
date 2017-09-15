//
//  GPAlertView.h
//  smartHome
//
//  Created by guiping on 2017/9/11.
//  Copyright © 2017年 galaxywind. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, HeaderviewLocation) {
    HeaderviewLocationLeft,     // 箭头在左边
    HeaderviewLocationCenter,   // 箭头在右边
    HeaderviewLocationRight,    // 箭头在中间
};

@class GPAlertView;
@protocol GPAlertViewDelegate <NSObject>
@optional
- (void)didSlectedItemWithTitle:(NSString *)title;
- (void)didSlectedItemWithTitle:(NSString *)title indexPath:(NSIndexPath *) indexPath;
@end


@interface GPAlertView : UIButton

@property (nonatomic, weak) id <GPAlertViewDelegate> target;
@property (nonatomic, strong) UIColor *textColor;       // 文字颜色 Default whiteColor
@property (nonatomic, strong) UIColor *lineColor;       // 线条颜色 Default whiteColor
@property (nonatomic, strong) UIFont *titleFont;        // 文字大小 Default 17
@property (nonatomic, assign) CGFloat contentViewWidth; // 显示内容的宽度（导航） Default 178
@property (nonatomic, assign) CGFloat tbCellHeight;     // 单元格高度 Default 60
@property (nonatomic, assign) HeaderviewLocation headerViewAlignment; // 三角形的位置（左中右）
@property (nonatomic, assign) CGRect imgFrame;      // 图片的frame
@property (nonatomic, assign) CGRect lbTitleFrame;  // 标签的frame
@property (nonatomic, assign) NSUInteger cellNumbersMax;    // 设置显示cell的个数，当大于该设定值，tb可以滚动 默认超过3个时tb可以滚动

// 导航栏提示框（有图）
- (instancetype) initWithNavigationItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray imageNameArray:(NSArray *) imageNameArray;

// 导航栏提示框（无图）
- (instancetype) initWithNavigationItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray;

// 设置三角形的顶点在中间时，设置距离左边或者右边的距离
-(void)setHeaderviewLocationCenterDistance:(CGFloat) distance;

// 显示
- (void) showInViewController:(UIViewController *) viewController;

// 事件处理
- (void) didSelectItemWithTitleCallBack:(void(^)(NSString *title))callBack;
@end



































@interface GpHeaderView : UIImageView
@property (nonatomic, assign) BOOL isOpposite;
@property (nonatomic, strong) UIColor *layerFillColor;
@end


@interface itemCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *lbTitle;

@end
