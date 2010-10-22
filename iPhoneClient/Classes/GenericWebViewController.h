//
//  GenericWebViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/18/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";

@interface GenericWebViewController : UIViewController <UIWebViewDelegate> {
	NSURLRequest *request;
	UIWebView *webview;
	AppModel *appModel;	
}

-(void) setModel:(AppModel *)model;
-(void) setURL:(NSString*)urlString;

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidStartLoad:(UIWebView *)webView;


@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (readwrite, copy) NSURLRequest *request;





@end
