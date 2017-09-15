//
//  GPMoreView.m
//  NavigationMore
//
//  Created by guiping on 2017/9/15.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import "GPAlertView.h"

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

static NSString *tbViewIdentifier = @"tbViewIdentifier";

@interface GPAlertView()
{
    CAShapeLayer *sanjiaoxinglayer;
    UITableView *tbView;
    UICollectionView *colorCollectionView;
    CAShapeLayer *maskLayer;
    UIBezierPath *maskPath;
    CGRect reItemRect;
}

@property (nonatomic, copy) void(^selectedItemCallBack)(NSString *title);
@property (nonatomic, weak) UIViewController *superController;

//@property (nonatomic, assign) cl_handle_t handle;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *imageNameSource;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) BgView *bgView;
@property (nonatomic, strong) UIImageView *trangleView;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) CGRect customFrame;
@property (nonatomic, assign) BOOL transformed;
@property (nonatomic, assign) CGFloat collectionViewCellWidth; // 单元格宽度（cell） ?
@property (nonatomic, assign) CGSize sanSize;           // 三角形的宽高 Default 12 7
@property (nonatomic, assign) CGFloat corneradius;      // 圆角 Default 5
@property (nonatomic, assign) CGFloat middleDistance;      // 到三角形中心的距离（仅当headerViewAligenmentCenter有效）
@end


@implementation GPAlertView

- (void) showInViewController:(UIViewController *) viewController{
    _superController = viewController;
    //self.target = (id<GPAlertViewDelegate>)viewController;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(instancetype)initWithItemRect:(CGRect)itemRect titleArray:(NSArray *)titleArray imageNameArray:(NSArray *)imageNameArray{
    _imageNameSource = imageNameArray;
    if (titleArray.count != imageNameArray.count) {
        NSLog(@"文字和图片个数不一致");
        return  nil;
    }
    return [self initWithItemRect:itemRect titleArray:titleArray];
}

- (instancetype) initWithItemRect:(CGRect)itemRect titleArray:(NSArray *) titleArray{
    if (!titleArray || titleArray.count == 0) {
        NSLog(@"********传入的数据源****有误********");
        return nil;
    }
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        //NSLog(@"源 %@", NSStringFromCGRect(itemRect));
        
        _dataSource = titleArray;
        
        // 默认值
        _bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        _textColor = [UIColor whiteColor];
        _lineColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _titleFont = [UIFont systemFontOfSize:17];
        _tbCellHeight = 60.0f;
        _collectionViewCellWidth = 60.0f;
        _contentViewWidth = 150.0f;
        _sanSize = CGSizeMake(12, 7); // 原图大小 36 * 21
        _corneradius = 5;
        _middleDistance = 0.0f;
        if (_imageNameSource) {
            _imgFrame = CGRectMake(14, 14, 32, 32);
            _lbTitleFrame = CGRectMake(58, 0, _contentViewWidth - 58, _tbCellHeight);
        }
        else{
            _lbTitleFrame = CGRectMake(10, 0, _contentViewWidth - 10, _tbCellHeight);
        }
        _cellNumbersMax = 3;
        
        
        reItemRect = itemRect;
        self.frame = CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height);
        [self addTarget:self action:@selector(tapClick) forControlEvents:UIControlEventTouchUpInside];
        CGFloat height = _dataSource.count > _cellNumbersMax ? _tbCellHeight * _cellNumbersMax : _tbCellHeight *_dataSource.count;
        
        
        _bgView = [[BgView alloc] initWithFrame:CGRectMake(0, 0, _contentViewWidth, height + 7)];
        [self addSubview:_bgView];
        _bgView.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = _bgColor;
        [_bgView addSubview:_contentView];
        _trangleView = [[UIImageView alloc] init];
        _trangleView.backgroundColor = _bgColor;
        [_bgView addSubview:_trangleView];
        
        if (itemRect.origin.y < SCREEN_SIZE.height - CGRectGetHeight(_bgView.bounds)) {//箭头在上
            //_contentView.frame = CGRectMake(0, 7, _bgView.bounds.size.width, _bgView.bounds.size.height - 7);
            if (CGRectGetMidX(itemRect) > SCREEN_SIZE.width - 35) { // 右边
                _headerViewAlignment = GPHeaderviewLocationRight;
                [self setfrssssss];
                
            }
            else if (CGRectGetMidX(itemRect) < 35){ // 左边
                _headerViewAlignment = GPHeaderviewLocationLeft;
                [self setfrssssss];
            }
            else{ // 中间
                _headerViewAlignment = GPHeaderviewLocationCenter;
                [self setfrssssss];
            }
        }
        else{ // 箭头在下
            CGRect bgframe = _bgView.frame;
            bgframe.origin.y = CGRectGetMinY(itemRect) - bgframe.size.height;//  系统创建的item的Y=7
            if (CGRectGetMidX(itemRect) > SCREEN_SIZE.width - 35) { // 右边
                _headerViewAlignment = GPHeaderviewLocationRight;
                [self setfrssssss];
            }
            else if (CGRectGetMidX(itemRect) < 35){ // 左边
                _headerViewAlignment = GPHeaderviewLocationLeft;
                [self setfrssssss];
            } // 中间
            else{
                _headerViewAlignment = GPHeaderviewLocationCenter;
                [self setfrssssss];
            }
            _bgView.frame = bgframe;
        }
        
        // 内容展示
        tbView = [[UITableView alloc] initWithFrame:_contentView.bounds];
        tbView.backgroundColor = [UIColor clearColor];
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (_dataSource.count < _cellNumbersMax + 1) {
            tbView.scrollEnabled = NO;
        }
        [_contentView addSubview:tbView];
        _bgView.layer.masksToBounds = YES;
        tbView.dataSource = (id<UITableViewDataSource>)self;
        tbView.delegate = (id<UITableViewDelegate>)self;
    }
    return self;
}

#pragma mark ---------setter方法------------
- (void) refresh{
    if (tbView) {
        [tbView reloadData];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [self refresh];
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    [self refresh];
}

-(void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    [self refresh];
}

-(void)setCellNumbersMax:(NSUInteger)cellNumbersMax{
    _cellNumbersMax = cellNumbersMax;
    CGFloat height = _dataSource.count > _cellNumbersMax ? _tbCellHeight * _cellNumbersMax : _tbCellHeight *_dataSource.count;
    _bgView.frame = CGRectMake(0, 0, _contentViewWidth, height + 7);
    [self setfrssssss];
    if (_dataSource.count < _cellNumbersMax +1) {
        tbView.scrollEnabled = NO;
    }
    else{
        tbView.scrollEnabled = YES;
    }
    [self refresh];
}

-(void)setHeaderViewAlignment:(GPHeaderviewLocation)headerViewAlignment{
    _headerViewAlignment = headerViewAlignment;
    [self setfrssssss];
}

-(void)setTbCellHeight:(CGFloat)tbCellHeight{
    _tbCellHeight = tbCellHeight;
    CGFloat height = _dataSource.count > _cellNumbersMax ? _tbCellHeight * _cellNumbersMax : _tbCellHeight *_dataSource.count;
    _bgView.frame = CGRectMake(0, 0, _contentViewWidth, height + 7);
    CGRect lbTRect = _lbTitleFrame;
    _lbTitleFrame = CGRectMake(lbTRect.origin.x, lbTRect.origin.y, lbTRect.size.width, lbTRect.size.height < _tbCellHeight?lbTRect.size.height:_tbCellHeight);
    [self setfrssssss];
}

-(void)setContentViewWidth:(CGFloat)contentViewWidth{
    _contentViewWidth = contentViewWidth;
    CGRect bgframe = _bgView.frame;
    bgframe.size.width = _contentViewWidth;
    _bgView.frame = bgframe;
    [self setfrssssss];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    _bgColor = backgroundColor;
    _contentView.backgroundColor = _bgColor;
//    if (_headerView.image) {
//        //_headerView.image = ThemeImageWithUIColor(@"小三角",_bgColor);
//    }
//    else{
//        _headerView.layerFillColor = _bgColor;
//    }
}

- (void)setImgFrame:(CGRect)imgFrame{
    _imgFrame = imgFrame;
    [self refresh];
}

-(void)setLbTitleFrame:(CGRect)lbTitleFrame{
    _lbTitleFrame = lbTitleFrame;
    [self refresh];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)];
    _customFrame = frame;
    CGRect bgframe = _bgView.frame;
    _customFrame.size.width = bgframe.size.width;
    _customFrame.size.height = bgframe.size.height;
    bgframe.origin.x = frame.origin.x;
    bgframe.origin.y = frame.origin.y;
    _bgView.frame = bgframe;
}

- (void) setfrssssss{
    CGRect bgframe = _bgView.frame;
    if (reItemRect.origin.y < SCREEN_SIZE.height - CGRectGetHeight(_bgView.bounds)) {//箭头在上
        _contentView.frame = CGRectMake(0, 7, _bgView.bounds.size.width, _bgView.bounds.size.height - 7);
        bgframe.origin.y = reItemRect.origin.y <= 7 ? 64 : CGRectGetMaxY(reItemRect);
        if (_headerViewAlignment == GPHeaderviewLocationRight) {
            bgframe.origin.x = CGRectGetMaxX(reItemRect) - _contentViewWidth;
            if (CGRectGetMidX(reItemRect) > SCREEN_SIZE.width - 35) {
                bgframe.origin.x = SCREEN_SIZE.width - 16 - _contentViewWidth;
            }
            _trangleView.frame = CGRectMake(CGRectGetMaxX(_bgView.bounds) - 12, 0, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else if (_headerViewAlignment == GPHeaderviewLocationLeft) {
            bgframe.origin.x = CGRectGetMinX(reItemRect);
            if (CGRectGetMidX(reItemRect) < 35) {
                bgframe.origin.x = 16;
            }
            _trangleView.frame = CGRectMake(0, 0, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else{
            bgframe.origin.x = CGRectGetMidX(reItemRect) - _contentViewWidth / 2;
            _trangleView.frame = CGRectMake(CGRectGetMidX(_bgView.bounds) - 6, 0, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
    }
    else{ // 箭头在下
        _contentView.frame = CGRectMake(0, 0, _bgView.bounds.size.width, _bgView.bounds.size.height - 7);
        bgframe.origin.y = CGRectGetMinY(reItemRect) - bgframe.size.height;
        if (_headerViewAlignment == GPHeaderviewLocationRight) {
            bgframe.origin.x = CGRectGetMaxX(reItemRect) - _contentViewWidth;
            _trangleView.frame = CGRectMake(CGRectGetMaxX(_bgView.bounds) - 12, CGRectGetMaxY(_bgView.bounds) - 7, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else if (_headerViewAlignment == GPHeaderviewLocationLeft) {
            bgframe.origin.x = CGRectGetMinX(reItemRect);
            _trangleView.frame = CGRectMake(0, CGRectGetMaxY(_bgView.bounds) - 7, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else{
            bgframe.origin.x = CGRectGetMidX(reItemRect) - _contentViewWidth / 2;
            _trangleView.frame = CGRectMake(CGRectGetMidX(_bgView.bounds) - 6, CGRectGetMaxY(_bgView.bounds) - 7, 12, 7);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
    }
    _bgView.frame = bgframe;
    if (_customFrame.size.width) {
        _bgView.frame = _customFrame;
    }
    tbView.frame = _contentView.bounds;
    maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = _contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    _contentView.layer.mask = maskLayer;
}

- (void)tapClick
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.alpha = 1.0f;
        [self removeFromSuperview];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tbViewIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tbViewIdentifier];
        if (_imageNameSource) {
            UIImageView *imView = [[UIImageView alloc] initWithFrame:_imgFrame];
            [cell.contentView addSubview:imView];
            imView.tag = 400;
            [cell.contentView addSubview:imView];
            
            UILabel *ctrlTitleLable = [[UILabel alloc] initWithFrame:_lbTitleFrame];
            ctrlTitleLable.tag = 401;
            [cell.contentView addSubview:ctrlTitleLable];
        }
        else{
            UILabel *ctrlTitleLable = [[UILabel alloc] initWithFrame:_lbTitleFrame];
            ctrlTitleLable.tag = 401;
            [cell.contentView addSubview:ctrlTitleLable];
        }
        
        if (indexPath.row < _dataSource.count - 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _tbCellHeight - 1, 178, 1)];
            [cell.contentView addSubview:lineView];
            lineView.backgroundColor = [_lineColor colorWithAlphaComponent:0.7];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *img = (UIImageView*)[cell viewWithTag:400];
    UILabel *lbTitle = (UILabel*)[cell viewWithTag:401];
    if (img) {
        img.image = [UIImage imageNamed:_imageNameSource[indexPath.row]];
    }
    
    NSString *title = _dataSource[indexPath.row];
    //    if ([title isEqualToString:ACTION_NAME_LANGUAGE_CN] || [title isEqualToString:ACTION_NAME_LANGUAGE_EN]) {
    //        if ([GxAppConfig sharedInstance].lang == Chinese) {
    //            title = ACTION_NAME_LANGUAGE_EN;
    //        }else{
    //            title = ACTION_NAME_LANGUAGE_CN;
    //        }
    //    }
    lbTitle.font = _titleFont;
    lbTitle.numberOfLines = 0;
    lbTitle.textColor = _textColor;
    lbTitle.text = title;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tbCellHeight;
}

-(void)tableView:(UITableView*)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = _dataSource[indexPath.row];
    [self onSelectRowWithTitle:title];
}

#pragma mark - 私有方法 点击事件处理
- (void)onSelectRowWithTitle:(NSString *)title
{
    [self tapClick];
    if (self.selectedItemCallBack) {
        self.selectedItemCallBack(title);
    }
    
    if (self.target && [self.target respondsToSelector:@selector(didSlectedItemWithTitle:)]) {
        [self.target didSlectedItemWithTitle:title];
    }
    else {
        
    }
}

- (void) didSelectItemWithTitleCallBack:(void(^)(NSString *title))callBack
{
    if (callBack) {
        self.selectedItemCallBack = ^(NSString *itemTitle){
            callBack(itemTitle);
        };
    }
}
@end

@implementation BgView



@end
