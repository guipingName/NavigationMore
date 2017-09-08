//
//  GXMoreButtonAlertView.h
//  test
//
//  Created by guiping on 2017/9/4.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPAlertView;
@protocol GPAlertViewDelegate <NSObject>
@optional
- (void)didSlectedItemWithTitle:(NSString *)title;
- (void)didSlectedItemWithTitle:(NSString *)title indexPath:(NSIndexPath *) indexPath;
@end

@class sanjiaoxingView;
@interface GPAlertView : UIButton

@property (nonatomic, weak) id <GPAlertViewDelegate> target;
@property (nonatomic, copy) void(^selectedItemCallBack)(NSString *title);
@property (nonatomic, strong) UIColor *textColor;       // 文字颜色 Default whiteColor
@property (nonatomic, strong) UIFont *titleFont;        // 文字大小 Default 17
@property (nonatomic, assign) CGFloat contentViewWidth; // 单元格宽度（导航） Default 178
@property (nonatomic, assign) CGFloat tbCellHeight;     // 单元格高度（导航） Default 60
@property (nonatomic, assign) CGFloat collectionViewCellWidth; // 单元格宽度（cell） ?
@property (nonatomic, assign) CGSize sanSize;           // 三角形的宽高 Default 20 10?
@property (nonatomic, assign) CGFloat corneradius;      // 圆角 Default 5?
@property (nonatomic, assign) NSTextAlignment sanAlignment;


// 导航栏提示框（有图）
- (instancetype) initWithNavigationIItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray imageNameArray:(NSArray *) imageNameArray;

// 导航栏提示框（无图）
- (instancetype) initWithNavigationItemRect:(CGRect)itemRect data:(NSArray *) dataSource;

// 单元格cell提示框
- (instancetype)initWithTableViewCell:(CGRect)cellRect data:(NSArray *) dataSource indexPath:(NSIndexPath *) indexPath;

// 显示
- (void) show;

@end


@interface sanjiaoxingView : UIImageView
@property (nonatomic, assign) BOOL isOppsote;
@property (nonatomic, strong) UIColor *layerFillColor;
@end


@interface itemCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *lbTitle;

@end
