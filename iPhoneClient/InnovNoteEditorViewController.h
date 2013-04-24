//
//  InnovNoteEditorViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 4/5/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "AsyncMediaTouchableImageView.h"
#import "Note.h"
#import "ARISMoviePlayerViewController.h"

typedef enum {
	kInnovAudioRecorderNoAudio,
	kInnovAudioRecorderRecording,
	kInnovAudioRecorderAudio,
	kInnovAudioRecorderPlaying
} InnovAudioRecorderModeType;

@interface InnovNoteEditorViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, AsyncMediaTouchableImageViewDelegate, AsyncMediaImageViewDelegate> {
    
    __weak IBOutlet AsyncMediaTouchableImageView *imageView;
    __weak IBOutlet UITextView *captionTextView;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UIButton *deleteAudioButton;
    __weak IBOutlet UITableView *tagTableView;
    
    UIBarButtonItem *cancelButton;

    Note *note;
    id __unsafe_unretained delegate;
    BOOL isEditing;
    
    BOOL newNote;
    BOOL cancelled;
    BOOL hasAudioToUpload;
    NSMutableArray *gameTagList;
    
    ARISMoviePlayerViewController *ARISMoviePlayer;
    
    //AudioMeter *meter;
	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
	NSURL *soundFileURL;
	InnovAudioRecorderModeType mode;
	NSTimer *recordLengthCutoffTimer;
    
}

@property (nonatomic)                    Note *note;
@property (nonatomic, unsafe_unretained) id delegate;
@property (readwrite)                    BOOL isEditing;

- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)deleteAudioButtonPressed:(id)sender;

@end