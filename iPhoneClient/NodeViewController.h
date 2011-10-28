//
//  NodeViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Node.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncImageView.h"

@interface NodeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
	Node *node;
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	UITableView *tableView;
	UIButton *mediaPlaybackButton;
    BOOL isLink;
    BOOL hasMedia;
    BOOL imageLoaded, webLoaded;
    
    AsyncImageView *mediaImageView;
    UIActivityIndicatorView *spinner;
    NSArray *cellArray;
}

@property(readwrite, retain) Node *node;
@property(readwrite, assign) BOOL isLink;
@property(readwrite, assign) BOOL hasMedia;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain)UIActivityIndicatorView *spinner;
@property(nonatomic,retain)AsyncImageView *mediaImageView;
@property(nonatomic, retain)NSArray *cellArray;

- (void)imageFinishedLoading;
- (void) refreshView;

@end

