//
//  GXMoreButtonAlertView.h
//  test
//
//  Created by guiping on 2017/9/4.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, HeaderviewLocation) {
    HeaderviewLocationLeft,
    HeaderviewLocationCenter,
    HeaderviewLocationRight,
};

@class GPAlertView;
@protocol GPAlertViewDelegate <NSObject>
@optional
- (void)didSlectedItemWithTitle:(NSString *)title;
- (void)didSlectedItemWithTitle:(NSString *)title indexPath:(NSIndexPath *) indexPath;
@end


@interface GPAlertView : UIButton

@property (nonatomic, weak) id <GPAlertViewDelegate> target;
@property (nonatomic, copy) void(^selectedItemCallBack)(NSString *title);
@property (nonatomic, strong) UIColor *textColor;       // 文字颜色 Default whiteColor
@property (nonatomic, strong) UIColor *lineColor;       // 线条颜色 Default whiteColor
@property (nonatomic, strong) UIFont *titleFont;        // 文字大小 Default 17
@property (nonatomic, assign) CGFloat contentViewWidth; // 显示内容的宽度（导航） Default 178
@property (nonatomic, assign) CGFloat tbCellHeight;     // 单元格高度（导航） Default 60
@property (nonatomic, assign) HeaderviewLocation headerViewAlignment; // 三角形的位置（左中右）
@property (nonatomic, assign) CGRect imgFrame;      // 图片的frame
@property (nonatomic, assign) CGRect lbTitleFrame;  // 标签的frame
@property (nonatomic, assign) NSUInteger cellNumbersMax;    // 设置显示cell的个数，当大于该设定值，tb可以滚动 默认超过3个时tb可以滚动

// 导航栏提示框（有图）
- (instancetype) initWithNavigationItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray imageNameArray:(NSArray *) imageNameArray;

// 导航栏提示框（无图）
- (instancetype) initWithNavigationItemRect:(CGRect)itemRect data:(NSArray *) dataSource;

// 单元格cell提示框
- (instancetype)initWithTableViewCell:(CGRect)cellRect data:(NSArray *) dataSource indexPath:(NSIndexPath *) indexPath;

// 显示
- (void) show;

- (void)onSelectRowWithTitleCallBack:(void(^)(NSString *title))callBack;
@end


@interface HeaderView : UIImageView
@property (nonatomic, assign) BOOL isOpposite;
@property (nonatomic, strong) UIColor *layerFillColor;
@end


@interface itemCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *lbTitle;

@end
