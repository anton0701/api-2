//
//  ViewController.m
//  api
//
//  Created by AKrylov on 06.08.13.
//  Copyright (c) 2013 AKrylov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    BOOL hasBeenUpdated;
    BOOL loggedOut;
}

@end

#define CLIENT_ID  @"428ca8b646004a5ba2c1fbe7c664b3bc"
#define REDIRECT_URI @"https://yandex.ru"
#define AUTHENTIFICATIONSTRING @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token"
#define IMAGES_PER_REQUEST 7
#define kRefreshDeltaY -8


@implementation ViewController

- (void)viewDidLoad
{
    loggedOut = NO;
    hasBeenUpdated = NO;
    _photoMutableArray = [[NSMutableArray alloc]init];
    _wasUpdatedAfterElement = NO;
    _wasUpdatedBeforeElement = NO;
    _mediaIDArray = [[NSMutableArray alloc]init];
    _userHasLikedArray = [[NSMutableArray alloc]init];
    self.web.delegate = self;
    NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:
                                  [NSString stringWithFormat:AUTHENTIFICATIONSTRING, CLIENT_ID, REDIRECT_URI]]];
    
    [self.web loadRequest:request];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    
    if ([request.URL.absoluteString rangeOfString:@"#"].location != NSNotFound)
    {
        NSString* params = [[request.URL.absoluteString componentsSeparatedByString:@"#"] objectAtIndex:1];
        self.accessToken = [params stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:self.accessToken forKey:@"userAccessTokenKey"];
        [defaults synchronize];
        _photoMutableArray = [[NSMutableArray alloc]init];
        _mediaIDArray = [[NSMutableArray alloc]init];
        _userHasLikedArray = [[NSMutableArray alloc]init];

        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
        self.web.hidden = YES;
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 350;
        [self.view addSubview:_table];
        [self getSelfFeed];

    }
    
	return YES;
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [self setLogOutBarButton:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger number = 0;
    if (_photoMutableArray.count) number = _photoMutableArray.count;
    return number;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    InstagramTableViewCell *itvc = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (itvc == nil)
    {
        itvc = [[InstagramTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        itvc.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        int userHasLikedInt = [_userHasLikedArray[indexPath.row]intValue];

        button.frame = CGRectMake(10, 300, 80, 40);
        [itvc addSubview:button];
        itvc.likeButton = button;
        
        if (userHasLikedInt == 1)
            [button setTitle:@"Dislike" forState:UIControlStateNormal];
        else
            [button setTitle:@"Like" forState:UIControlStateNormal];

        [itvc.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *propertiesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        propertiesButton.frame = CGRectMake(225, 300, 85, 40);
        [itvc addSubview:propertiesButton];
        [propertiesButton setTitle:@"Properties" forState:UIControlStateNormal];
        itvc.propertiesButton = propertiesButton;

    }

    return itvc;
}

-(void)getSelfFeed
{
    dispatch_queue_t getSelfFeedQ = dispatch_queue_create("Get self feed", NULL);
    dispatch_async(getSelfFeedQ, ^
                   {
                       _wasUpdatedAfterElement = YES;
                       NSString *url = [[NSString alloc]initWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%i", self.accessToken, IMAGES_PER_REQUEST];
                       NSError *error = nil;
                       NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSWindowsCP1251StringEncoding error:nil] dataUsingEncoding:NSWindowsCP1251StringEncoding];
                       NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
                       NSArray *dataArray = [NSArray arrayWithArray:[results objectForKey:@"data"]];
                       if ([dataArray count])
                       {
                           _min_id = [[dataArray lastObject]objectForKey:@"id"];
                           _max_id = [dataArray [0] objectForKey:@"id"];
                           for (NSInteger i=0; i < [dataArray count]; i++)
                           {
                               NSString *stringUrl = [[NSString alloc]initWithFormat:@"%@", [[[[dataArray objectAtIndex:i]objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"url"]];
                               //Картинка
                               NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:stringUrl]];
                               UIImage *image = [UIImage imageWithData:imageData];
                               [_photoMutableArray addObject:image];
                               //ID картинки
                               NSString* media_id = [dataArray[i] objectForKey:@"id"];
                               [_mediaIDArray insertObject:media_id atIndex:i];
                               //Ставил ли лайк пользователь
                               CFBooleanRef userHasLikedBoolRef = (__bridge CFBooleanRef)([dataArray[i] objectForKey:@"user_has_liked"]);
                               if (userHasLikedBoolRef == kCFBooleanTrue)
                                   [_userHasLikedArray insertObject:[NSNumber numberWithInt:1] atIndex:i];
                               else
                                   [_userHasLikedArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
                               
                               if (i % 3 == 2)
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (_table)
                                           [_table reloadData];});
                               }
                           }
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (!_table.hidden)
                                   [_table reloadData];
                           });
                       }
                       _wasUpdatedAfterElement = NO;
                       hasBeenUpdated = YES;
                   });
}
-(void)getSelfFeedBeforeElement:(NSString*)element
{
    dispatch_queue_t getSelfPrevFeedQ = dispatch_queue_create("Get self previous feed", NULL);
    dispatch_async(getSelfPrevFeedQ, ^
                   {
                       _wasUpdatedAfterElement = YES;
                       NSString *url = [[NSString alloc]initWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&max_id=%@&count=%i", self.accessToken, _min_id, IMAGES_PER_REQUEST];

                       NSError *error = nil;
                       NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSWindowsCP1251StringEncoding error:nil] dataUsingEncoding:NSWindowsCP1251StringEncoding];
                       NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;

                       NSArray *dataArray = [NSArray arrayWithArray:[results objectForKey:@"data"]];

                       if ([dataArray count])
                       {
                           id id_min_id = [[dataArray lastObject]objectForKey:@"id"];
                           if ([id_min_id isKindOfClass:[NSString class]])
                               _min_id = id_min_id;
                           for (NSInteger i = 0; i < [dataArray count]; i++)

                           {
                               //Загрузка картинки
                               NSString *stringUrl = [[NSString alloc]initWithFormat:@"%@", [[[[dataArray objectAtIndex:i]objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"url"]];
                               NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:stringUrl]];
                               UIImage *image = [UIImage imageWithData:imageData];
                               [_photoMutableArray addObject:image];
                               //
                               //Получение media_id, необходимое для отправки лайков и получения свойств
                               NSString* media_id = [dataArray[i] objectForKey:@"id"];
                               [_mediaIDArray addObject:media_id];
                               //
                               CFBooleanRef userHasLikedBoolRef = (__bridge CFBooleanRef)([dataArray[i] objectForKey:@"user_has_liked"]);
                               if (userHasLikedBoolRef == kCFBooleanTrue)
                                   [_userHasLikedArray addObject:[NSNumber numberWithInt:1]];
                               else
                                   [_userHasLikedArray addObject:[NSNumber numberWithInt:0]];

                               if (i % 3 == 2)
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (_table)
                                           [_table reloadData];});
                               }
                           }

                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (_table)
                                   [_table reloadData];
                           });

                       }
                       _wasUpdatedAfterElement = NO;
                   });

}
-(void)getSelfFeedAfterElement:(NSString*)element
{
    dispatch_queue_t getSelfNextFeedQ = dispatch_queue_create("Get self next feed", NULL);
    dispatch_async(getSelfNextFeedQ, ^
                   {
                       _wasUpdatedBeforeElement = YES;
                       NSString *url = [[NSString alloc]initWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&min_id=%@&count=%i", self.accessToken, _max_id, IMAGES_PER_REQUEST];
                       NSError *error = nil;
                       NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSWindowsCP1251StringEncoding error:nil] dataUsingEncoding:NSWindowsCP1251StringEncoding];
                       NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
                       NSArray *dataArray = [NSArray arrayWithArray:[results objectForKey:@"data"]];

                       if ([dataArray count])
                       {
                           id id_max_id = [dataArray[0]objectForKey:@"id"];
                           if ([id_max_id isKindOfClass:[NSString class]])
                               _max_id = id_max_id;
                           for (NSInteger i = [dataArray count] - 1; i >= 0; i--)
                           {
                               NSString *stringUrl = [[NSString alloc]initWithFormat:@"%@", [[[[dataArray objectAtIndex:i]objectForKey:@"images"]objectForKey:@"standard_resolution"]objectForKey:@"url"]];
                               NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:stringUrl]];
                               UIImage *image = [UIImage imageWithData:imageData];
                               [_photoMutableArray insertObject:image atIndex:0];
                               
                               //Получение media_id, необходимое для отправки лайков и получения свойств
                               NSString* media_id = [dataArray[i] objectForKey:@"id"];
                               [_mediaIDArray insertObject:media_id atIndex:i];
                               //
                               CFBooleanRef userHasLikedBoolRef = (__bridge CFBooleanRef)([dataArray[i] objectForKey:@"user_has_liked"]);
                               if (userHasLikedBoolRef == kCFBooleanTrue)
                                   [_userHasLikedArray insertObject:[NSNumber numberWithInt:1] atIndex:i];
                               else
                                   [_userHasLikedArray insertObject:[NSNumber numberWithInt:0] atIndex:i];

                           }
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (_table)
                                   [_table reloadData];
                           });
                       }
                       _wasUpdatedBeforeElement = NO;
                   });

}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell = nil;
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramTableViewCell *itvc = [[InstagramTableViewCell alloc]init];
    itvc = (InstagramTableViewCell*)cell;
    
    itvc.imageView.image = [_photoMutableArray objectAtIndex:indexPath.row];
    if ((indexPath.row == _photoMutableArray.count - 3) && (indexPath.row > 2) && (!_wasUpdatedAfterElement))
        [self getSelfFeedBeforeElement:_max_id];
    
    int wasMediaLiked = [_userHasLikedArray[indexPath.row]intValue];
    NSLog(@"%i", wasMediaLiked);
    if (wasMediaLiked == 1)
    {
        [itvc.likeButton setTitle:@"Dislike" forState:UIControlStateNormal];
    }
    else
    {
        [itvc.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ((scrollView.contentOffset.y < kRefreshDeltaY) && (!_wasUpdatedBeforeElement) && (hasBeenUpdated))
    {
        [self getSelfFeedAfterElement:nil];
    }
}

- (void)likeButtonPressed:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_table];
    NSIndexPath *indexPath = [_table indexPathForRowAtPoint:buttonPosition];
    UIButton *likeBut = sender;
    
    if (indexPath != nil)
    {
        if ([likeBut.titleLabel.text isEqualToString:@"Like"])
        {
            [likeBut setTitle:@"Dislike" forState:UIControlStateNormal];
            _userHasLikedArray[indexPath.row] = [NSNumber numberWithInt:1];
            [self like:_mediaIDArray[indexPath.row]];
        }
        else
        {
            [likeBut setTitle:@"Like" forState:UIControlStateNormal];
            _userHasLikedArray[indexPath.row] = [NSNumber numberWithInt:0];
            [self dislike:_mediaIDArray[indexPath.row]];
        }
    }
}

-(void)like:(NSString*)media_id
{
    
    dispatch_queue_t likeQ = dispatch_queue_create("like media", NULL);
    dispatch_async(likeQ, ^
                   {
                       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes", media_id]];
                       NSString *postString = [[NSString alloc]initWithFormat:@"access_token=%@", self.accessToken];
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                       [request setHTTPMethod:@"POST"];
                       [request setValue:[NSString stringWithFormat:@"%d",[postString length]] forHTTPHeaderField:@"Content-Length"];
                       [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                       [request setHTTPBody:[postString dataUsingEncoding:NSASCIIStringEncoding]];
                       NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                       [connection start];
                   });
}
-(void)dislike:(NSString*)media_id
{
    dispatch_queue_t dislikeQ = dispatch_queue_create("dislike media", NULL);
    dispatch_async(dislikeQ, ^
                   {
                       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", media_id, self.accessToken]];

                       NSString *postString = [[NSString alloc]initWithFormat:@""];
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                       [request setHTTPMethod:@"DELETE"];
                       [request setValue:[NSString stringWithFormat:@"%d",[postString length]] forHTTPHeaderField:@"Content-Length"];
                       [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                       [request setHTTPBody:[postString dataUsingEncoding:NSASCIIStringEncoding]];
                       NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                       [connection start];
                   });

}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row with number %i", indexPath.row);
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    PhotoPropertiesViewController *photoPropertiesViewController = [[PhotoPropertiesViewController alloc]
                                                    initWithNibName:@"PhotoPropertiesViewController" bundle:nil];
    
    [self.navigationController pushViewController:photoPropertiesViewController animated:YES];
}
- (IBAction)logOut:(id)sender
{
    [_table removeFromSuperview];
    _table = nil;
    [_table setHidden:YES];
    hasBeenUpdated = NO;
    _wasUpdatedAfterElement = NO;
    _wasUpdatedBeforeElement = NO;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userAccessTokenKey"];
    [defaults synchronize];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                            [NSURL URLWithString:@"http://instagram.com/accounts/logout/"]];
    
    [self.web loadRequest:request];
    loggedOut = YES;
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (loggedOut)
    {
        NSURLRequest* request2 =
        [NSURLRequest requestWithURL:[NSURL URLWithString:
                                      [NSString stringWithFormat:AUTHENTIFICATIONSTRING, CLIENT_ID, REDIRECT_URI]]];
        
        [self.web loadRequest:request2];
        [_web setHidden:NO];
        loggedOut = NO;

    }
}
@end
