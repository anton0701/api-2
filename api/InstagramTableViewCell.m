//
//  InstagramTableViewCell.m
//  api
//
//  Created by AKrylov on 14.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import "InstagramTableViewCell.h"

@implementation InstagramTableViewCell
#define CORNER_RADIUS 5
#define IMAGE_SIZE 230

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake((self.bounds.size.width - IMAGE_SIZE) / 2, (self.bounds.size.height - IMAGE_SIZE) / 2, IMAGE_SIZE, IMAGE_SIZE);
    
//    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.likeButton.frame = CGRectMake(5, 5, 60, 30);
//    [self.contentView addSubview: self.likeButton];

}

@end
