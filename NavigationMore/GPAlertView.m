//
//  GXMoreButtonAlertView.m
//  test
//
//  Created by guiping on 2017/9/4.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import "GPAlertView.h"
#import "UIImage+RTTint.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, AlertViewMode) {
    AlertViewModeNavigation,    // 导航
    AlertViewModeCell,          // cell
};


@interface GPAlertView()<UITableViewDataSource, UITableViewDelegate>
{
    CAShapeLayer *sanjiaoxinglayer;
    UITableView *tbView;
    UICollectionView *colorCollectionView;
    CAShapeLayer *maskLayer;
    UIBezierPath *maskPath;
    CGRect reItemRect;
}
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *imageNameSource;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) HeaderView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) AlertViewMode type;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) BOOL transformed;
@property (nonatomic, assign) CGFloat collectionViewCellWidth; // 单元格宽度（cell） ?
@property (nonatomic, assign) CGSize sanSize;           // 三角形的宽高 Default 20 10?
@property (nonatomic, assign) CGFloat corneradius;      // 圆角 Default 5
@end

static NSString *tbViewIdentifier = @"tableViewIdentifier";
static NSString *cwViewIdentifier = @"collecrtionViewIdentifier";
@implementation GPAlertView

#pragma mark ---------初始化方法------------
- (instancetype)initWithNavigationItemRect:(CGRect)itemRect data:(NSArray *) dataSource{
    return [self initWithType:AlertViewModeNavigation Item:itemRect data:dataSource];
}

-(instancetype)initWithNavigationItemRect:(CGRect)itemRect titleArray:(NSArray *)titleArray imageNameArray:(NSArray *)imageNameArray{
    _imageNameSource = imageNameArray;
    if (titleArray.count != imageNameArray.count) {
        NSLog(@"文字和图片个数不一致");
        return  nil;
    }
    return [self initWithType:AlertViewModeNavigation Item:itemRect data:titleArray];
}

-(instancetype)initWithTableViewCell:(CGRect)cellRect data:(NSArray *)dataSource indexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    return [self initWithType:AlertViewModeCell Item:cellRect data:dataSource];
}

- (instancetype)initWithType:(AlertViewMode) type Item:(CGRect)itemRect data:(NSArray *) dataSource{
    if (!dataSource || dataSource.count == 0) {
        NSLog(@"********传入的数据源****有误********");
        return nil;
    }
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        //NSLog(@"源 %@", NSStringFromCGRect(itemRect));
        
        _dataSource = dataSource;
        
        
        // 默认值
        _bgColor = [UIColor blackColor];
        _textColor = [UIColor whiteColor];
        _lineColor = [UIColor whiteColor];
        _titleFont = [UIFont systemFontOfSize:17];
        _tbCellHeight = 60.0f;
        _collectionViewCellWidth = 60.0f;
        _contentViewWidth = 178.0f;
        _sanSize = CGSizeMake(18, 10.5); // 原图大小 36 * 21
        _corneradius = 5;
        _headerViewAlignment = HeaderviewLocationCenter;
        if (_imageNameSource) {
            _imgFrame = CGRectMake(14, 14, 32, 32);
            _lbTitleFrame = CGRectMake(58, 0, _contentViewWidth - 58, _tbCellHeight);
        }
        else{
            _lbTitleFrame = CGRectMake(10, 0, _contentViewWidth - 10, _tbCellHeight);
        }
        _cellNumbersMax = 3;
        
        
        reItemRect = itemRect;
        _type = type;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        [self addTarget:self action:@selector(tapClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        _headerView = [[HeaderView alloc] init];
        [self addSubview:_headerView];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = _bgColor;
        
        switch (type) {
            case AlertViewModeNavigation:
            {
                CGFloat orgY = itemRect.origin.y <= 7 ? 65 : CGRectGetMaxY(itemRect);
                CGFloat sanX = CGRectGetMidX(itemRect) - _sanSize.width / 2;
                if (CGRectGetMidX(itemRect) > ScreenWidth - 35) {
                    CGRect sanRect = CGRectMake(CGRectGetMaxX(itemRect) - 12 - _sanSize.width, orgY, _sanSize.width, _sanSize.height);
                    _headerViewAlignment = HeaderviewLocationRight;
                    [self setHeaderViewFrame:sanRect];
                }
                else if (CGRectGetMidX(itemRect) < 35){
                    CGRect sanRect = CGRectMake(16, orgY, _sanSize.width, _sanSize.height);
                    _headerViewAlignment = HeaderviewLocationLeft;
                    [self setHeaderViewFrame:sanRect];
                }
                else{
                    CGRect sanRect = CGRectMake(sanX, orgY, _sanSize.width, _sanSize.height);
                    [self setHeaderViewFrame:sanRect];
                }
                
                // 内容展示
                tbView = [[UITableView alloc] initWithFrame:_contentView.bounds];
                tbView.backgroundColor = [UIColor clearColor];
                tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
                if (_dataSource.count < _cellNumbersMax + 1) {
                    tbView.scrollEnabled = NO;
                }
                [_contentView addSubview:tbView];
                tbView.dataSource = self;
                tbView.delegate = self;
                
            }
                break;
            case AlertViewModeCell:
            {
                _contentViewWidth = _dataSource.count > 4? _collectionViewCellWidth * 4 : _collectionViewCellWidth * dataSource.count;
                if (itemRect.origin.y < 100) {
                    _headerView.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, CGRectGetMaxY(itemRect), _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - _contentViewWidth) / 2, CGRectGetMaxY(_headerView.frame), _contentViewWidth, 30);
                }
                else{
                    _headerView.isOpposite = YES;
                    _headerView.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, itemRect.origin.y - _sanSize.height, _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - _contentViewWidth) / 2, CGRectGetMinY(_headerView.frame) - 30, _contentViewWidth, 30);
                }
                
                maskLayer = [[CAShapeLayer alloc]init];
                maskLayer.frame = _contentView.bounds;
                
                maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft |UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
                maskLayer.path = maskPath.CGPath;
                _contentView.layer.mask = maskLayer;
                
                // 内容展示
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                layout.minimumLineSpacing = 0;
                layout.itemSize = CGSizeMake(_collectionViewCellWidth, 30);
                layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
                
                colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _contentView.bounds.size.width, _contentView.bounds.size.height) collectionViewLayout:layout];
                colorCollectionView.backgroundColor = [UIColor clearColor];
                colorCollectionView.bounces = NO;
                colorCollectionView.showsHorizontalScrollIndicator = NO;
                [_contentView addSubview:colorCollectionView];
                
                [colorCollectionView registerClass:[itemCell class] forCellWithReuseIdentifier:cwViewIdentifier];
                colorCollectionView.dataSource = (id<UICollectionViewDataSource>)self;;
                colorCollectionView.delegate = (id<UICollectionViewDelegate>)self;
            }
            default:
                break;
        }
        [self addSubview:_contentView];
    }
    return self;
}

- (void) setHeaderViewFrame:(CGRect) frame{
    _headerView.frame = frame;
    UIImage *image = [[UIImage imageNamed:@"小三角"] rt_tintedImageWithColor:_bgColor];
    _headerView.image = image;
    
    CGFloat height = 0;
    if (_type == AlertViewModeNavigation) {
        height = _dataSource.count > _cellNumbersMax ? _tbCellHeight * _cellNumbersMax : _tbCellHeight *_dataSource.count;
        if (_headerViewAlignment == NSTextAlignmentRight) { // 三角形固定在右边
            if (_transformed) {
                _headerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }
            for (CALayer *layer in _headerView.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
            _contentView.frame = CGRectMake(CGRectGetMaxX(_headerView.frame) - _contentViewWidth, CGRectGetMaxY(_headerView.frame), _contentViewWidth, height);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else if (_headerViewAlignment == NSTextAlignmentLeft) { //三角形固定在左边
            _transformed = YES;
            for (CALayer *layer in _headerView.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
            _headerView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _contentView.frame = CGRectMake(CGRectGetMinX(_headerView.frame), CGRectGetMaxY(_headerView.frame), _contentViewWidth, height);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else{
            _headerView.image = nil;
            _contentView.frame = CGRectMake(CGRectGetMidX(_headerView.frame) - _contentViewWidth / 2, CGRectGetMaxY(_headerView.frame), _contentViewWidth, height);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
    }
    else{
        
    }
    tbView.frame = _contentView.bounds;
    maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = _contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    _contentView.layer.mask = maskLayer;
}

#pragma mark ---------setter方法------------
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

-(void)setHeaderViewAlignment:(HeaderviewLocation)headerViewAlignment{
    _headerViewAlignment = headerViewAlignment;
    CGRect frame = _headerView.frame;
    [self setHeaderViewFrame:frame];
}

-(void)setCellNumbersMax:(NSUInteger)cellNumbersMax{
    _cellNumbersMax = cellNumbersMax;
    CGRect frame = _headerView.frame;
    [self setHeaderViewFrame:frame];
    if (_dataSource.count < _cellNumbersMax +1) {
        tbView.scrollEnabled = NO;
    }
    else{
        tbView.scrollEnabled = YES;
    }
    [self refresh];
}

-(void)setTbCellHeight:(CGFloat)tbCellHeight{
    _tbCellHeight = tbCellHeight;
    CGRect frame = _headerView.frame;
    CGRect lbTRect = _lbTitleFrame;
    _lbTitleFrame = CGRectMake(lbTRect.origin.x, lbTRect.origin.y, lbTRect.size.width, lbTRect.size.height < _tbCellHeight?lbTRect.size.height:_tbCellHeight);
    [self setHeaderViewFrame:frame];
}

-(void)setContentViewWidth:(CGFloat)contentViewWidth{
    _contentViewWidth = contentViewWidth;
    CGRect frame = _headerView.frame;
    [self setHeaderViewFrame:frame];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    _bgColor = backgroundColor;
    _contentView.backgroundColor = _bgColor;
    if (_headerView.image) {
        _headerView.image = [[UIImage imageNamed:@"小三角"] rt_tintedImageWithColor:_bgColor];
    }
    else{
        _headerView.layerFillColor = _bgColor;
    }
}

- (void)setImgFrame:(CGRect)imgFrame{
    _imgFrame = imgFrame;
    [self refresh];
}

-(void)setLbTitleFrame:(CGRect)lbTitleFrame{
    _lbTitleFrame = lbTitleFrame;
    [self refresh];
}

- (void) refresh{
    if (tbView) {
        [tbView reloadData];
    }
    else{
        [colorCollectionView reloadData];
    }
}


- (void) show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
// --------end----------


































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
    [self removeFromSuperview];
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = _dataSource[indexPath.row];
    [self didSlectedItem:title];
}

- (void)onSelectRowWithTitleCallBack:(void(^)(NSString *title))callBack{
    if (callBack) {
        self.selectedItemCallBack = ^(NSString *title){
            callBack(title);
        };
    }
}

- (void) didSlectedItem:(NSString *) title{
    if (self.selectedItemCallBack) {
        self.selectedItemCallBack(title);
    }
    if (self.target && [self.target respondsToSelector:@selector(didSlectedItemWithTitle:)]) {
        [self.target didSlectedItemWithTitle:title];
    }
    else {
        
    }
}

#pragma mark UICollectionViewDataSource回调方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    itemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cwViewIdentifier forIndexPath:indexPath];
    cell.lbTitle.textColor = _textColor;
    cell.lbTitle.font = _titleFont;
    cell.lbTitle.text = _dataSource[indexPath.row];
    if (indexPath.row < _dataSource.count - 1) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_collectionViewCellWidth - 1, 0, 1, 30)];
        [cell.contentView addSubview:line];
        line.backgroundColor = _lineColor;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self removeFromSuperview];
    NSString *title = _dataSource[indexPath.row];
    if (self.target && [self.target respondsToSelector:@selector(didSlectedItemWithTitle:indexPath:)]) {
        [self.target didSlectedItemWithTitle:title indexPath:_indexPath];
        _indexPath = nil;
    }
}


//-------------

- (void)tapClick
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1.0f;
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface HeaderView()

@property (nonatomic, strong) CAShapeLayer *sanlayer;

@end

@implementation HeaderView

-(instancetype)init{
    if (self = [super init]) {
        _isOpposite = NO;
        _layerFillColor = [UIColor blackColor];
    }
    return self;
}

-(void)setLayerFillColor:(UIColor *)layerFillColor{
    _layerFillColor = layerFillColor;
    _sanlayer.fillColor = _layerFillColor.CGColor;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
//    for (CALayer *layer in self.layer.sublayers) {
//        [layer removeFromSuperlayer];
//    }
    [_sanlayer removeFromSuperlayer];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    if (!_isOpposite) {
        // 三角形顶角在上
        [path moveToPoint:CGPointMake(0, self.bounds.size.height)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width / 2, 0)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
        [path closePath];
    }
    else{
        // 三角形顶角在下
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
        [path closePath];
    }
   
    _sanlayer = [CAShapeLayer layer];
    _sanlayer.frame = self.bounds;
    _sanlayer.path = path.CGPath;
    [self.layer addSublayer:_sanlayer];
    
    
    _sanlayer.fillColor = _layerFillColor.CGColor;
    
}

@end

@interface itemCell(){
    UILabel *label;
}

@end

@implementation itemCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 1, CGRectGetHeight(self.frame))];
        _lbTitle.textColor = [UIColor whiteColor];
        _lbTitle.textAlignment = NSTextAlignmentCenter;
        _lbTitle.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_lbTitle];
    }
    return self;
}

@end
