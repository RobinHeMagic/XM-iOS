//
//  ScaleOriginalPhotoView.m
//  PickerController
//
//  Created by sunxb on 16/8/27.
//  Copyright © 2016年 sunxb. All rights reserved.
//

#import "ScaleOriginalPhotoView.h"

#define KViewWidth  [UIScreen mainScreen].bounds.size.width
#define KViewHeight [UIScreen mainScreen].bounds.size.height

static CGRect oldFrame;
CGFloat oldImgWidth;
CGFloat oldImgHeight;

@interface ScaleOriginalPhotoView ()
@property (nonatomic,assign) CGFloat lastScale;
@end

@implementation ScaleOriginalPhotoView
- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 1;
    }
    return self;
}

- (void)scaleOrigimalPhoto:(UIImageView *)currentImgView showOriginalImg:(UIImage *)showImg {
    
    UIImage * currentImg = currentImgView.image;
    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;

    oldFrame = [currentImgView convertRect:currentImgView.bounds toView:mainWindow];
    oldImgWidth  = currentImg.size.width;
    oldImgHeight  = currentImg.size.height;
    
    UIImageView * newImgView= [[UIImageView alloc] initWithFrame:oldFrame];
    newImgView.contentMode = UIViewContentModeScaleAspectFill;
    newImgView.clipsToBounds = YES; // ~
    newImgView.userInteractionEnabled = YES;
    newImgView.image = showImg;
    newImgView.tag = 100;
    [self addSubview:newImgView];
    [mainWindow addSubview:self];
    
    // 添加手势
    //tap
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImg:)];
    tap.numberOfTapsRequired = 1;
    [newImgView addGestureRecognizer:tap];
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat newWidth = KViewWidth;
        CGFloat newHeight = newWidth/(oldImgWidth*1.0/oldImgHeight);
        CGFloat yPosition = (KViewHeight-newHeight)/2.0;
        newImgView.frame = CGRectMake(0, yPosition, newWidth, newHeight);
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark 手势
// 点按
- (void)tapOnImg:(UITapGestureRecognizer *)tapRecognize {
    self.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0];
    [UIView animateWithDuration:0.3 animations:^{
        tapRecognize.view.frame = oldFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
