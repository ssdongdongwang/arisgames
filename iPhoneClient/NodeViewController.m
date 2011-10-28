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
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncImageView.h"
#import "webpageViewController.h"
#import "WebPage.h"
#import <AVFoundation/AVFoundation.h>

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
@synthesize node, tableView, isLink, hasMedia,spinner, mediaImageView, cellArray;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieLoadStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:nil];
        self.isLink=NO;
        self.mediaImageView = [[AsyncImageView alloc]init];
        self.mediaImageView.delegate = self;
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    NSLog(@"NodeViewController: Displaying Node '%@'",self.node.name);
    self.title = self.node.name;
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent = YES;
    
    
    //Setup the Image View/Video Preview Image (if needed)
    Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];
    
    //Check if the plaque has media
    if(([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"] || [media.type isEqualToString: @"Image"]) && media.url) hasMedia = YES;
    else hasMedia = NO;
    
    //Create Image/AV Cell
    UITableViewCell *imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mediaCell"];
    
    if ([media.type isEqualToString: @"Image"] && media.url) {
        NSLog(@"NodeVC: cellForRowAtIndexPath: This is an Image Plaque");
        
        self.mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if(!self.mediaImageView.loaded) {
            [self.mediaImageView loadImageFromMedia:media];
        }
        
        //Setup the cell as an image
        imageCell.backgroundView = mediaImageView;
        imageCell.backgroundView.layer.masksToBounds = YES;
        imageCell.backgroundView.layer.cornerRadius = 10.0;
        imageCell.userInteractionEnabled = NO;
    }
    else if(([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"]) && media.url)
    {
        NSLog(@"NodeVC: This is an A/V Plaque");
        //Setup the Button
        mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        [mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        mediaPlaybackButton.enabled = NO;
        
        
        //Create movie player object
        mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];
        
        //Syncronously Create a thumbnail for the button
        UIImage *videoThumb = [[mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact] retain];
        
        imageLoaded = YES;
        NSLog(@"NodeVC: videoThumb frame size is : %f, %f", videoThumb.size.width, videoThumb.size.height);
        UIGraphicsBeginImageContext(CGSizeMake(320.0f, 240.0f));
        [videoThumb drawInRect:CGRectMake(0, 0, 320.0f, 240.0f)];
        UIImage *videoThumbSized = UIGraphicsGetImageFromCurrentImageContext();    
        UIGraphicsEndImageContext();
        [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
        [videoThumb release];
        [videoThumbSized release];
        
        //Setup the cell as the video preview button
        imageCell.backgroundView = mediaPlaybackButton;
        imageCell.backgroundView.layer.masksToBounds = YES;
        imageCell.backgroundView.layer.cornerRadius = 10.0;
        imageCell.userInteractionEnabled = YES;
        imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        imageCell.frame = mediaPlaybackButton.frame;
    }
    
    //Setup the Description Webview and begin loading content
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    webView.delegate = self;
    webView.backgroundColor =[UIColor clearColor];
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
	[webView loadHTMLString:htmlDescription baseURL:nil];
    
    //Create Description Web View Cell
    UITableViewCell *webCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionCell"];
    webCell.userInteractionEnabled = NO;
    CGRect descriptionFrame = [webView frame];	
    descriptionFrame.origin.x = 10;
    [webView setFrame:descriptionFrame];
    webCell.backgroundView = webView;
    webCell.backgroundColor = [UIColor clearColor];
    
    //Create continue button cell
    UITableViewCell *buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"continueButtonCell"];
    buttonCell.textLabel.text = @"Tap To Continue";
    buttonCell.textLabel.textAlignment = UITextAlignmentCenter;
    
    //Setup the cellArray
    if(hasMedia) self.cellArray = [[NSArray alloc] initWithObjects:imageCell,webCell,buttonCell, nil];
    else self.cellArray = [[NSArray alloc] initWithObjects:webCell,buttonCell, nil];
    
}

#pragma mark UIWebViewDelegate Methods

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    CGRect descriptionFrame = [webView frame];	
    descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight+5);
    [webView setFrame:descriptionFrame];	
    
    //Find the webView spinner and remove it
    for(int x = 0; x < [webView.subviews count]; x ++){
        if([[webView.subviews objectAtIndex:x] isKindOfClass:[UIActivityIndicatorView class]])
            [[webView.subviews objectAtIndex:x] removeFromSuperview];
    }
    
    //Find the description cell and update it's frame with the new size
    for(int x = 0; x < 2; x++){
        if([[(UITableViewCell *)[self.cellArray objectAtIndex:x] reuseIdentifier] isEqualToString:@"descriptionCell"]){
            [(UITableViewCell *)[self.cellArray objectAtIndex:x] setFrame:webView.frame];
        }
    }
    
    //Check to see if all the async loading is complete and we should reload the table with the new sizes
    webLoaded = YES;
    if((webLoaded && imageLoaded && hasMedia) ||(webLoaded && !hasMedia)) [self.tableView reloadData];
    
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
navigationType:(UIWebViewNavigationType)navigationType{
    
    if(self.isLink) {
        webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
        WebPage *temp = [[WebPage alloc]init];
        temp.url = [[request URL]absoluteString];
        webPageViewController.webPage = temp;
        webPageViewController.delegate = self;
        [self.navigationController pushViewController:webPageViewController animated:NO];
        [webPageViewController release];
        
        return NO;
    }
    else{
        [spinner startAnimating];
        spinner.center = webView.center;
        spinner.backgroundColor = [UIColor blackColor];
        [webView addSubview:spinner];
        return YES;
    }
}

#pragma mark AsyncImageView Delegate Methods
-(void)imageFinishedLoading{
    NSLog(@"NodeVC: imageFinishedLoading with size: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    
    if(self.mediaImageView.image.size.width > 0){
        [self.mediaImageView setContentScaleFactor:(float)(320/self.mediaImageView.image.size.width)];
        self.mediaImageView.frame = CGRectMake(0, 0, 320, self.mediaImageView.contentScaleFactor*self.mediaImageView.image.size.height);
        NSLog(@"NodeVC: Image resized to: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
        [(UITableViewCell *)[self.cellArray objectAtIndex:0] setFrame:mediaImageView.frame];
    }
    
    //Check to see if all the async loading is complete and we should reload the table with the new sizes
    imageLoaded = YES;
    if((webLoaded && imageLoaded && hasMedia) || (webLoaded && !hasMedia))   [self.tableView reloadData];
    
}


#pragma mark Button Handlers
- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId];
	
	
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:NO];
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    
}

- (IBAction)continueButtonTouchAction{
    NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId];
	
    //Remove thyself from the screen
	[self dismissModalViewControllerAnimated:NO];
    
    //Check if this was the game complete Node and if so, display the "Start Over" tab
    if((node.nodeId == [AppModel sharedAppModel].currentGame.completeNodeId) && 
       ([AppModel sharedAppModel].currentGame.completeNodeId != 0)){
        
        ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *tab;
        for(int i = 0;i < [appDelegate.tabBarController.customizableViewControllers count];i++){
            tab = [[appDelegate.tabBarController.customizableViewControllers objectAtIndex:i] title];
            tab = [tab lowercaseString];
            
            if([tab isEqualToString:@"start over"])
                appDelegate.tabBarController.selectedIndex = i;
        }
    }
    
}

-(IBAction)playMovie:(id)sender {
    [mMoviePlayer.moviePlayer play];
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}


#pragma mark MPMoviePlayerController Notification Handlers


- (void)movieLoadStateChanged:(NSNotification*) aNotification{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
    
	if( state & MPMovieLoadStateUnknown ) {
		NSLog(@"NodeViewController: Unknown Load State");
	}
	if( state & MPMovieLoadStatePlayable ) {
		NSLog(@"NodeViewController: Playable Load State");
        [mediaPlaybackButton setTitle:NSLocalizedString(@"TouchToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = YES;	
		//[self playMovie:nil];
	} 
	if( state & MPMovieLoadStatePlaythroughOK ) {
		NSLog(@"NodeViewController: Playthrough OK Load State");
        
	} 
	if( state & MPMovieLoadStateStalled ) {
		NSLog(@"NodeViewController: Stalled Load State");
	} 
    
}


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellArray count];
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
    
    return [self.cellArray objectAtIndex:indexPath.section];
    
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [self.cellArray objectAtIndex:indexPath.section];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 2 || (indexPath.section == 1 && !hasMedia)) [self continueButtonTouchAction];
    else [self playMovie:nil];
}


#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"NodeViewController: Dealloc");
    
	[mMoviePlayer release];
	[node release];
	[tableView release];
	[mediaPlaybackButton release];
	//remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end