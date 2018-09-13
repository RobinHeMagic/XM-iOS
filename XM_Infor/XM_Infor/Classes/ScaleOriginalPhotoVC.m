//
//  ScaleOriginalPhotoVC.m
//  XM_Infor
//
//  Created by Robin He on 07/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

#import "ScaleOriginalPhotoVC.h"
#import "SelectCollectionViewCell.h"

#define KViewWidth  [UIScreen mainScreen].bounds.size.width
#define KViewHeight [UIScreen mainScreen].bounds.size.height

static CGRect oldFrame;
CGFloat oldImgWidth;
CGFloat oldImgHeight;

@interface ScaleOriginalPhotoVC ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,assign) CGFloat lastScale;
@property (nonatomic,strong) NSArray * allPhotos;
@property (nonatomic,strong) UIImageView * currentImagV;
@property (nonatomic,strong) UICollectionView * collectView;
@property (nonatomic,strong) NSMutableArray * imageVItems;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSMutableDictionary * dict;
@property (nonatomic,strong) NSArray * rectsItems;
@property (nonatomic,copy) NSString * rectStr;
@end

@implementation ScaleOriginalPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 1;
    
    [self setUpUI];
    
   self.dict = [NSMutableDictionary dictionary];
    
}

- (void)setUpUI {
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KViewWidth, KViewHeight) collectionViewLayout:layout];
    [self.collectView registerClass:[SelectCollectionViewCell class] forCellWithReuseIdentifier:@"SelectCollectionViewCell"];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.pagingEnabled = YES;
    [self.view addSubview:self.collectView];
    
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return  self.allPhotos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectCollectionViewCell" forIndexPath:indexPath];
    
    CGFloat newWidth = KViewWidth;
    UIImage * ima = self.allPhotos[indexPath.row];
    CGFloat newHeight = newWidth/(ima.size.width *1.0 /ima.size.height);
    CGFloat yPosition = (KViewHeight-newHeight)/2.0;
    

    cell.selectImageV.image = self.allPhotos[indexPath.row];
      cell.selectImageV.userInteractionEnabled = YES;
    if (self.index == indexPath.row) {
        
        cell.selectImageV.frame = oldFrame;
      
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImg:)];
        tap.numberOfTapsRequired = 1;
        [cell.selectImageV addGestureRecognizer:tap];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat newWidth = KViewWidth;
            CGFloat newHeight = newWidth/(oldImgWidth*1.0/oldImgHeight);
            CGFloat yPosition = (KViewHeight-newHeight)/2.0;
            cell.selectImageV.frame = CGRectMake(0, yPosition, newWidth, newHeight);
            
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        cell.selectImageV.frame = CGRectMake(0, yPosition, KViewWidth, newHeight);

    }
    
    [self.dict setObject:cell.selectImageV forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    
    return cell;
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KViewWidth, KViewHeight);
}

- (void)scaleOrigimalPhoto:(UIImageView *)currentImgView showOriginalImg:(UIImage *)showImg andOriginalImgs:(NSArray*)images cgrects:(NSArray*)rects{
    
    self.rectsItems = rects;
    
    self.allPhotos = images;
    UIImage * currentImg = currentImgView.image;
    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
    
    oldFrame = [currentImgView convertRect:currentImgView.bounds toView:mainWindow];
    oldImgWidth  = currentImg.size.width;
    oldImgHeight  = currentImg.size.height;
    
    [mainWindow addSubview:self.view];
    
    self.index = [images indexOfObject:showImg];
    
     [self.collectView setContentOffset:CGPointMake(self.index * KViewWidth, 0)];
}



- (void)tapOnImg:(UITapGestureRecognizer *)tapRecognize {
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0];

    [UIView animateWithDuration:0.3 animations:^{
        tapRecognize.view.frame = oldFrame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }];
}

-(void)tapGestClick:(UITapGestureRecognizer*)tapRecognizer
{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        tapRecognizer.view.frame = CGRectFromString(self.rectStr);
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            [self.view removeFromSuperview];
            
            [self removeFromParentViewController];
        }
    }];
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int resultf = (int)scrollView.contentOffset.x / KViewWidth;
    
    self.rectStr = self.rectsItems[resultf];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestClick:)];
  
    
    self.currentImagV = [self.dict objectForKey:[NSString stringWithFormat:@"%d",resultf]];
    
    [self.currentImagV addGestureRecognizer:tap];
}




@end
