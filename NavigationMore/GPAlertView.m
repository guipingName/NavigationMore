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
@property (nonatomic, strong) sanjiaoxingView *sanjiaoxing;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) AlertViewMode type;
@property (nonatomic, strong) UIColor *bgColor;
//@property (nonatomic, assign) SanAlignment sanAlignment;
@property (nonatomic, assign) NSUInteger a;
@end

static NSString *tbViewIdentifier = @"tableViewIdentifier";
static NSString *cwViewIdentifier = @"collecrtionViewIdentifier";
@implementation GPAlertView

#pragma mark ---------初始化方法------------
- (instancetype)initWithNavigationItemRect:(CGRect)itemRect data:(NSArray *) dataSource{
    return [self initWithType:AlertViewModeNavigation Item:itemRect data:dataSource];
}

-(instancetype)initWithNavigationIItemRect:(CGRect)itemRect titleArray:(NSArray *)titleArray imageNameArray:(NSArray *)imageNameArray{
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
        
        // 默认值
        _bgColor = [UIColor blackColor];
        _textColor = [UIColor whiteColor];
        _titleFont = [UIFont systemFontOfSize:17];
        _tbCellHeight = 60.0f;
        _collectionViewCellWidth = 60.0f;
        _contentViewWidth = 178.0f;
        _sanSize = CGSizeMake(18, 10.5); // 原图大小 36 * 21
        _corneradius = 5;
        _sanAlignment = NSTextAlignmentCenter;
        
        reItemRect = itemRect;
        _type = type;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        [self addTarget:self action:@selector(tapClick) forControlEvents:UIControlEventTouchUpInside];
        
        _dataSource = dataSource;
        
        _sanjiaoxing = [[sanjiaoxingView alloc] init];
        [self addSubview:_sanjiaoxing];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = _bgColor;
        
        switch (type) {
            case AlertViewModeNavigation:
            {
                CGFloat orgY = itemRect.origin.y == 0 ? 65 : CGRectGetMaxY(itemRect);
                CGFloat sanX = itemRect.origin.x + itemRect.size.width / 2 - _sanSize.width / 2;
                
                if (sanX > 300) { // 需要修改
                    CGRect sanRect = CGRectMake(CGRectGetMaxX(itemRect) - 12 - _sanSize.width, orgY, _sanSize.width, _sanSize.height);
                    _sanAlignment = NSTextAlignmentRight;
                    [self sanFrame:sanRect];
                }
                else if (sanX < 50){ // 需要修改
                    CGRect sanRect = CGRectMake(16, orgY, _sanSize.width, _sanSize.height);
                    _sanAlignment = NSTextAlignmentLeft;
                    [self sanFrame:sanRect];
                }
                else{
                    // todo:
                    CGRect sanRect = CGRectMake(sanX, orgY, _sanSize.width, _sanSize.height);
                   
                    [self sanFrame:sanRect];
                }
                
                // 内容展示
                tbView = [[UITableView alloc] initWithFrame:_contentView.bounds];
                tbView.backgroundColor = [UIColor clearColor];
                tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
                if (_dataSource.count < 6) {
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
                    _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, CGRectGetMaxY(itemRect), _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - _contentViewWidth) / 2, CGRectGetMaxY(_sanjiaoxing.frame), _contentViewWidth, 30);
                }
                else{
                    _sanjiaoxing.isOppsote = YES;
                    _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, itemRect.origin.y - _sanSize.height, _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - _contentViewWidth) / 2, CGRectGetMinY(_sanjiaoxing.frame) - 30, _contentViewWidth, 30);
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

- (void) sanFrame:(CGRect) frame{
    _sanjiaoxing.frame = frame;
    UIImage *image = [[UIImage imageNamed:@"小三角"] rt_tintedImageWithColor:_bgColor];
    _sanjiaoxing.image = image;
    
    CGFloat height = 0;
    if (_type == AlertViewModeNavigation) {
        height = _dataSource.count > 5 ? _tbCellHeight * 5 : _tbCellHeight *_dataSource.count;
        if (_sanAlignment == NSTextAlignmentRight) { // 三角形固定在右边
            if (_a ==3) {
                _sanjiaoxing.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }
            for (CALayer *layer in _sanjiaoxing.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
            _contentView.frame = CGRectMake(CGRectGetMaxX(_sanjiaoxing.frame) - _contentViewWidth, CGRectGetMaxY(_sanjiaoxing.frame), _contentViewWidth, height);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else if (_sanAlignment == NSTextAlignmentLeft) { //三角形固定在左边
            _a = 3;
            for (CALayer *layer in _sanjiaoxing.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
            _sanjiaoxing.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _contentView.frame = CGRectMake(CGRectGetMinX(_sanjiaoxing.frame), CGRectGetMaxY(_sanjiaoxing.frame), _contentViewWidth, height);
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
        else{
            _sanjiaoxing.image = nil;
            if (CGRectGetMinX(reItemRect) > ScreenWidth / 2) { // 右边的item
                _contentView.frame = CGRectMake(ScreenWidth - 16 - _contentViewWidth, CGRectGetMaxY(_sanjiaoxing.frame), _contentViewWidth, height);
            }
            else{
                _contentView.frame = CGRectMake(16, CGRectGetMaxY(_sanjiaoxing.frame), _contentViewWidth, height);
            }
            maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
        }
    }
    else{
        
    }
    
    maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = _contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    _contentView.layer.mask = maskLayer;
}

#pragma mark ---------setter方法------------
- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    if (tbView) {
        [tbView reloadData];
    }
    else{
        [colorCollectionView reloadData];
    }
}

-(void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    if (tbView) {
        [tbView reloadData];
    }
    else{
        [colorCollectionView reloadData];
    }
}

- (void)setSanSize:(CGSize)sanSize{
    
}

-(void)setSanAlignment:(NSTextAlignment)sanAlignment{
    _sanAlignment = sanAlignment;
    CGRect frame = _sanjiaoxing.frame;
    [self sanFrame:frame];
}



-(void)setTbCellHeight:(CGFloat)tbCellHeight{
    _tbCellHeight = tbCellHeight;
    CGRect frame = _sanjiaoxing.frame;
    [self sanFrame:frame];
}

-(void)setContentViewWidth:(CGFloat)contentViewWidth{
    _contentViewWidth = contentViewWidth;
    if (_sanAlignment == NSTextAlignmentCenter) {
        if (CGRectGetMinX(reItemRect) > ScreenWidth / 2) { // 右边的item
            if (CGRectGetMinX(_sanjiaoxing.frame) < ScreenWidth - 16 - _contentViewWidth) {
                _contentViewWidth = ScreenWidth - 16 - CGRectGetMinX(_sanjiaoxing.frame);
                _sanAlignment = NSTextAlignmentLeft;
            }
        }
        else{
            if (_contentViewWidth < CGRectGetMaxX(_sanjiaoxing.frame) - 16) {
                _contentViewWidth = CGRectGetMaxX(_sanjiaoxing.frame) - 16;
                _sanAlignment = NSTextAlignmentRight;
            }
        }
    }
    CGRect frame = _sanjiaoxing.frame;
    [self sanFrame:frame];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    _bgColor = backgroundColor;
    _contentView.backgroundColor = _bgColor;
    if (_sanjiaoxing.image) {
        _sanjiaoxing.image = [[UIImage imageNamed:@"小三角"] rt_tintedImageWithColor:_bgColor];
    }
    else{
        _sanjiaoxing.layerFillColor = _bgColor;
    }
}

-(void)setCorneradius:(CGFloat)corneradius{
    
}

- (void) refresh{
    
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
            UIImageView *imView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 32, 32)];
                [cell.contentView addSubview:imView];
            imView.tag = 400;
            [cell.contentView addSubview:imView];
            
            UILabel *ctrlTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(58, 0, 120, _tbCellHeight)];
            ctrlTitleLable.tag = 401;
            [cell.contentView addSubview:ctrlTitleLable];
        }
        else{
            UILabel *ctrlTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, _tbCellHeight)];
            ctrlTitleLable.tag = 401;
            [cell.contentView addSubview:ctrlTitleLable];
        }
        
        if (indexPath.row < _dataSource.count - 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _tbCellHeight - 1, 178, 1)];
            [cell.contentView addSubview:lineView];
            lineView.backgroundColor = [_textColor colorWithAlphaComponent:0.7];
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
        line.backgroundColor = _textColor;
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

@interface sanjiaoxingView()

@property (nonatomic, strong) CAShapeLayer *sanlayer;

@end

@implementation sanjiaoxingView

-(instancetype)init{
    if (self = [super init]) {
        _isOppsote = NO;
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
    if (!_isOppsote) {
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