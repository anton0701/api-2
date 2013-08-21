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
@interface ViewController : UIViewController<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, UINavigationControllerDelegate>

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
@property (strong, atomic) NSMutableArray *textIDArray;
@property (strong, atomic) NSMutableArray *usernameIDArray;
@property (strong, atomic) NSMutableArray *profilePictureIDArray;
@property (strong, atomic) NSMutableArray *likesCountArray;

//@property (strong, atomic) NSMutableArray *likeArray;
@property (strong, atomic) NSMutableArray *userHasLikedArray;
@property (strong, nonatomic) UINavigationController *navContr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutBarButton;
@property (strong, nonatomic) UIBarButtonItem *logOutButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)logOut:(id)sender;

@end
