//
//  ScaleOriginalPhotoVC.h
//  XM_Infor
//
//  Created by Robin He on 07/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScaleOriginalPhotoVC : UIViewController

- (void)scaleOrigimalPhoto:(UIImageView *)currentImgView showOriginalImg:(UIImage *)showImg andOriginalImgs:(NSArray*)images cgrects:(NSArray*)rects;

@end
