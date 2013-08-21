//
//  ViewController.h
//  api
//
//  Created by AKrylov on 06.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramTableViewCell.h"
//#import "AFNetworking.h"
#import "stdlib.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PhotoPropertiesViewController.h"
@interface ViewController : UIViewController<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *web;
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableArray* thumbnails;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, atomic) NSMutableArray *photoMutableArray;
@property (strong, atomic) NSString* min_id;
@property (strong, atomic) NSString* max_id;
@property (atomic) BOOL wasUpdatedAfterElement;
@property (atomic) BOOL wasUpdatedBeforeElement;
@property (strong, atomic) NSMutableArray *mediaIDArray;
//@property (strong, atomic) NSMutableArray *likeArray;
@property (strong, atomic) NSMutableArray *userHasLikedArray;
@property (strong, nonatomic) UINavigationController *navContr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutBarButton;

@property (weak, nonatomic) IBOutlet UIToolbar *logOutToolBar;
- (IBAction)logOut:(id)sender;

@end
