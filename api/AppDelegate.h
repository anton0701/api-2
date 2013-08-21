//
//  AppDelegate.h
//  api
//
//  Created by AKrylov on 06.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigationController;


@end
