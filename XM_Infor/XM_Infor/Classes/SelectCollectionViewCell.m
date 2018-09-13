//
//  SelectCollectionViewCell.m
//  XM_Infor
//
//  Created by Robin He on 07/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

#import "SelectCollectionViewCell.h"

@interface SelectCollectionViewCell()


@end
@implementation SelectCollectionViewCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//}

-(instancetype)initWithFrame:(CGRect)frame{
   
    if (self = [super initWithFrame:frame]) {
    
        self.selectImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 375, 300)];
        
        [self.contentView addSubview:self.selectImageV];
        
        self.selectImageV.clipsToBounds = YES;
        self.selectImageV.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

@end
