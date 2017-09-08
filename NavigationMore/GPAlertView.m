//
//  GXMoreButtonAlertView.m
//  test
//
//  Created by guiping on 2017/9/4.
//  Copyright © 2017年 pingui. All rights reserved.
//

#import "GPAlertView.h"

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
        //NSLog(@"ca %@", NSStringFromCGRect(itemRect));
        
        // 默认值
        _bgColor = [UIColor blackColor];
        _textColor = [UIColor whiteColor];
        _titleFont = [UIFont systemFontOfSize:17];
        _tbCellHeight = 60.0f;
        _collectionViewCellWidth = 60.0f;
        _contentViewWidth = 178.0f;
        _sanSize = CGSizeMake(15, 9);
        _corneradius = 5;
        
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
                _sanjiaoxing.frame = CGRectMake(sanX, orgY, _sanSize.width, _sanSize.height);
                
                CGFloat height = _dataSource.count > 5 ? _tbCellHeight * 5 : _tbCellHeight *_dataSource.count;
                _contentView.frame = CGRectMake(sanX > 185 ? (ScreenWidth - (_contentViewWidth + 10)):10, orgY + _sanSize.height, _contentViewWidth, height);
                maskLayer = [[CAShapeLayer alloc]init];
                maskLayer.frame = _contentView.bounds;
                [self refresh];
                _contentView.layer.mask = maskLayer;
                
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
                CGFloat width = _dataSource.count > 4? _collectionViewCellWidth * 4 : _collectionViewCellWidth * dataSource.count;
                if (itemRect.origin.y < 100) {
                    _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, CGRectGetMaxY(itemRect), _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - width) / 2, CGRectGetMaxY(_sanjiaoxing.frame), width, 30);
                }
                else{
                    _sanjiaoxing.isOppsote = YES;
                    _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(itemRect) - _sanSize.width / 2, itemRect.origin.y - _sanSize.height, _sanSize.width, _sanSize.height);
                    _contentView.frame = CGRectMake((ScreenWidth - width) / 2, CGRectGetMinY(_sanjiaoxing.frame) - 30, width, 30);
                }
                
                maskLayer = [[CAShapeLayer alloc]init];
                maskLayer.frame = _contentView.bounds;
                [self refresh];
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
    _sanSize = sanSize;
    CGRect rect = _sanjiaoxing.frame;
    CGRect contentRect = _contentView.frame;
    
    switch (_type) {
        case AlertViewModeNavigation:
        {
            // 导航
            CGFloat orgY = reItemRect.origin.y == 0 ? 65 : CGRectGetMaxY(reItemRect);
            _sanjiaoxing.frame = CGRectMake(rect.origin.x + rect.size.width / 2 - _sanSize.width / 2, rect.origin.y, _sanSize.width, _sanSize.height);
            _contentView.frame = CGRectMake(contentRect.origin.x, orgY + _sanSize.height, contentRect.size.width, contentRect.size.height);
        }
            break;
        case AlertViewModeCell:
            // cell
            if (reItemRect.origin.y < 100) {
                _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(reItemRect) - _sanSize.width / 2, CGRectGetMaxY(reItemRect), _sanSize.width, _sanSize.height);
                _contentView.frame = CGRectMake((ScreenWidth - contentRect.size.width) / 2, CGRectGetMaxY(_sanjiaoxing.frame), contentRect.size.width, 30);
            }
            else{
                _sanjiaoxing.isOppsote = YES;
                _sanjiaoxing.frame = CGRectMake(CGRectGetMidX(reItemRect) - _sanSize.width / 2, reItemRect.origin.y - _sanSize.height, _sanSize.width, _sanSize.height);
                _contentView.frame = CGRectMake((ScreenWidth - contentRect.size.width) / 2, CGRectGetMinY(_sanjiaoxing.frame) - 30, contentRect.size.width, 30);
            }
            break;
        default:
            break;
    }
    
    [self refresh];
}

- (void)setAlignment:(NSTextAlignment)alignment{
    _alignment = alignment;
    CGRect red = _contentView.frame;
    if (_alignment == NSTextAlignmentRight) { // 居右
        _contentView.frame = CGRectMake(CGRectGetMaxX(_sanjiaoxing.frame) - red.size.width, red.origin.y, red.size.width, red.size.height);
        tbView.frame = _contentView.bounds;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(_corneradius,_corneradius)];
    }
    else if (_alignment == NSTextAlignmentLeft) { // 居左
        _contentView.frame = CGRectMake(CGRectGetMinX(_sanjiaoxing.frame), red.origin.y, red.size.width, red.size.height);
        tbView.frame = _contentView.bounds;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
    }
    maskLayer.path = maskPath.CGPath;
}

-(void)setTbCellHeight:(CGFloat)tbCellHeight{
    if (!tbView) {
        return;
    }
    _tbCellHeight = tbCellHeight;
    CGRect red = _contentView.frame;
    CGFloat height = _dataSource.count > 5 ? _tbCellHeight * 5 : _tbCellHeight *_dataSource.count;
    _contentView.frame = CGRectMake(red.origin.x, red.origin.y, red.size.width, height);
    tbView.frame = _contentView.bounds;
    [self refresh];
}

-(void)setContentViewWidth:(CGFloat)contentViewWidth{
    if (!tbView) {
        return;
    }
    _contentViewWidth = contentViewWidth;
    
    CGRect red = _contentView.frame;
    CGFloat x = red.origin.x + 178 - _contentViewWidth > _sanjiaoxing.frame.origin.x ? _sanjiaoxing.frame.origin.x - 10 : red.origin.x + 178 - _contentViewWidth;
    _contentView.frame = CGRectMake(red.origin.x <= 16 ?10:x, red.origin.y, _contentViewWidth, red.size.height);
    tbView.frame = _contentView.bounds;
    [self refresh];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    _bgColor = backgroundColor;
    _contentView.backgroundColor = _bgColor;
    _sanjiaoxing.layerFillColor = _bgColor;
}

-(void)setCorneradius:(CGFloat)corneradius{
    _corneradius = corneradius;
    [self refresh];
}

- (void) refresh{
    maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft |UIRectCornerTopRight cornerRadii:CGSizeMake(_corneradius,_corneradius)];
    maskLayer.path = maskPath.CGPath;
}


- (void) show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
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
        img.backgroundColor = [UIColor whiteColor];
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
