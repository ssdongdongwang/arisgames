//
//  QRScannerViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import <ZXingWidgetController.h>
#import "ZBarReaderViewController.h"
#import "VPParentViewController.h"


@interface QRScannerViewController : UIViewController <UINavigationControllerDelegate, 
                                                        UIImagePickerControllerDelegate, 
                                                        ZXingDelegate, ZBarReaderDelegate>{
	IBOutlet UIButton *qrScanButton;
    IBOutlet UIButton *barcodeButton;
    IBOutlet UIButton *imageScanButton;
	IBOutlet UITextField *manualCode;
    NSString *resultText;
    UIImagePickerController *imageMatchingImagePickerController;
    UIBarButtonItem *cancelButton;
    float videoPlaybackTime[NUM_VIDEO_TARGETS];
}

@property (nonatomic) IBOutlet UIButton *qrScanButton;
@property (nonatomic) IBOutlet UIButton *barcodeButton;

@property (nonatomic) IBOutlet UIButton *imageScanButton;
@property (nonatomic) IBOutlet UITextField *manualCode;
@property (nonatomic) UIImagePickerController *imageMatchingImagePickerController;
@property (nonatomic) NSString *resultText;
@property (nonatomic) UIBarButtonItem *cancelButton;
@property (nonatomic) VPParentViewController *arParentViewController;

- (IBAction) scanButtonTapped;
- (void)cancelButtonTouch;
- (IBAction)qrScanButtonTouchAction: (id) sender;
- (IBAction)imageScanButtonTouchAction: (id) sender;
- (void) loadResult:(NSString *)result;
- (void) showARCamera;

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result;
- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller;


@end
