//
//  TagCell.h
//  ARIS
//
//  Created by Brian Thiel on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagCell : UITableViewCell{
    IBOutlet UILabel *nameLabel;
    IBOutlet UIImageView *checkImage;
}
@property(nonatomic,retain)IBOutlet UILabel *nameLabel;
@property(nonatomic,retain)IBOutlet UIImageView *checkImage;
@end