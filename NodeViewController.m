//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NodeViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "WebPageViewController.h"
#import "WebPage.h"
#import <AVFoundation/AVFoundation.h>
#import "AsyncMediaPlayerButton.h"
#import "UIImage+Scale.h"

static NSString * const OPTION_CELL = @"option";

NSString *const kPlaqueDescriptionHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"	}"
@"	a {color: #9999FF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@implementation NodeViewController

@synthesize node, hasMedia, imageLoaded, webLoaded, scrollView, mediaArea, webView, continueButton, webViewSpinner, mediaImageView;

- (id)initWithNode:(Node *)n
{
    if ((self = [super initWithNibName:@"NodeViewController" bundle:nil]))
    {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        self.node = n;
        AsyncMediaImageView *mediaImageViewAlloc = [[AsyncMediaImageView alloc]init];
        self.mediaImageView = mediaImageViewAlloc;
        self.mediaImageView.delegate = self;
        self.mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.title = self.node.name;
    
    //Setup the Image View/Video Preview Image (if needed)
    Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];
    if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString: kMediaTypeAudio] || [media.type isEqualToString: kMediaTypeImage]) && media.url) hasMedia = YES;
    else hasMedia = NO;
    
    mediaArea = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,10)];
    if ([media.type isEqualToString: kMediaTypeImage] && media.url)
    {
        if(!mediaImageView.loaded)
            [mediaImageView loadImageFromMedia:media];
        mediaImageView.frame = CGRectMake(0, 0, 320, 320);
        mediaArea.frame = CGRectMake(0, 0, 320, 320);
        [mediaArea addSubview:mediaImageView];        
    }
    else if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString:kMediaTypeAudio]) && media.url)
    {
        NSLog(@"NodeViewController: VideoURL: %@", media.url);
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presentingController:[RootViewController sharedRootViewController] preloadNow:NO];
        mediaArea.frame = CGRectMake(0, 0, 300, 240);
        [mediaArea addSubview:mediaButton];
        mediaArea.frame = CGRectMake(0, 0, 300, 240);
    }
    
    //Setup the Description Webview
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, mediaArea.frame.size.height + 20, 300, 10)];
    webView.delegate = self;
    webView.backgroundColor =[UIColor clearColor];
    if([webView respondsToSelector:@selector(scrollView)]){
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = NO;
    }
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
    webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
	[webView loadHTMLString:htmlDescription baseURL:nil];
    
    UIActivityIndicatorView *webViewSpinnerAlloc = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner = webViewSpinnerAlloc;
    self.webViewSpinner.center = webView.center;
    [self.webViewSpinner startAnimating];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    [webView addSubview:self.webViewSpinner];
    
    //Create continue button cell
    continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [continueButton setTitle:NSLocalizedString(@"TapToContinueKey", @"") forState:UIControlStateNormal];
    [continueButton setFrame:CGRectMake(0, webView.frame.origin.y + webView.frame.size.height + 20, 320, 45)];
    [continueButton addTarget:self action:@selector(continueButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup the scrollview
    //scrollView.frame = self.parentViewController.view.frame;
    scrollView.contentSize = CGSizeMake(320,continueButton.frame.origin.y + continueButton.frame.size.height + 50);
    if(hasMedia) [scrollView addSubview:mediaArea];
    [scrollView addSubview:webView];
    [scrollView addSubview:continueButton];
}

-(void)webViewDidFinishLoad:(UIWebView *)theWebView{
    webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
    [webView setFrame:CGRectMake(webView.frame.origin.x,
                                 webView.frame.origin.y,
                                 webView.frame.size.width,
                                 newHeight+5)];
    [continueButton setFrame:CGRectMake(continueButton.frame.origin.x ,
                                        webView.frame.origin.y + webView.frame.size.height + 20,
                                        continueButton.frame.size.width,
                                        continueButton.frame.size.height)];
    scrollView.contentSize = CGSizeMake(320,continueButton.frame.origin.y + continueButton.frame.size.height + 50);
    
    //Find the webCell spinner and remove it
    [webViewSpinner removeFromSuperview]; 
}

#pragma mark AsyncImageView Delegate Methods
-(void)imageFinishedLoading
{
    NSLog(@"NodeVC: imageFinishedLoading with size: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    /*
     if(self.mediaImageView.image.size.width > 0){
     [self.mediaImageView setContentScaleFactor:(float)(320/self.mediaImageView.image.size.width)];
     self.mediaImageView.frame = CGRectMake(0, 0, 300, self.mediaImageView.contentScaleFactor*self.mediaImageView.image.size.height);
     NSLog(@"NodeVC: Image resized to: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
     [(UITableViewCell *)[self.cellArray objectAtIndex:0] setFrame:mediaImageView.frame];
     }
     
     [tableView reloadData];
     */
}


#pragma mark Button Handlers
- (IBAction)backButtonTouchAction:(id)sender
{
	[delegate displayObjectViewControllerWasDismissed:self];
}

- (IBAction)continueButtonTouchAction
{
	[delegate displayObjectViewControllerWasDismissed:self];
}

#pragma mark MPMoviePlayerController Notification Handlers

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark Memory Management

- (void)dealloc
{
	NSLog(@"NodeViewController: Dealloc");
    webView.delegate = nil;
    [webView stopLoading];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end