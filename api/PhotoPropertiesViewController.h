//
//  PhotoPropertiesViewController.h
//  api
//
//  Created by Apple on 19.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPropertiesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickName;

@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *dateAdded;

@end
