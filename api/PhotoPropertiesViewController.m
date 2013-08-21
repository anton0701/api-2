//
//  PhotoPropertiesViewController.m
//  api
//
//  Created by Apple on 19.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import "PhotoPropertiesViewController.h"

@interface PhotoPropertiesViewController ()

@end

@implementation PhotoPropertiesViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.text.editable = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setAvatar:nil];
    [self setNickName:nil];
    [self setText:nil];
    [super viewDidUnload];
}
@end
