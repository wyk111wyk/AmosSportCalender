//
//  PersonalInfoCell.m
//  AmosSportDiary
//
//  Created by Amos Wu on 16/3/18.
//  Copyright © 2016年 Amos Wu. All rights reserved.
//

#import "PersonalInfoCell.h"
#import "CommonMarco.h"

@interface PersonalInfoCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@end

@implementation PersonalInfoCell

- (void)awakeFromNib {
    // Initialization code
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.height/2;
    _avatarImageView.layer.borderWidth = 1.3;
    _avatarImageView.layer.borderColor = MyLightGray.CGColor;
    _avatarImageView.layer.masksToBounds = YES;
    
    [_checkImageView setLayerShadow:MyLightGray offset:CGSizeMake(1, 1) radius:0.6];
    _checkImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIImage *photoImage = [[TMCache sharedCache] objectForKey:ATCacheKey(_userDataName)];
    if (photoImage) {
        _avatarImageView.image = photoImage;
    }else {
        SportImageStore *imageStore = [SportImageStore findFirstWithFormat:@" WHERE imageKey = '%@' ", _userDataName];
        if (imageStore) {
            NSString *avatarStr = imageStore.sportPhoto;
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:avatarStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            photoImage = [UIImage imageWithData:imageData];
            [[TMCache sharedCache] setObject:photoImage forKey:ATCacheKey(_userDataName)];
            _avatarImageView.image = photoImage;
        }
    }
    _avatarImageView.layer.masksToBounds = YES;
    
    // Configure the view for the selected state
    if (_isMain) {
        _checkImageView.hidden = NO;
        self.backgroundColor = MyWhite;
    }else {
        self.backgroundColor = BackgroundColor;
    }
}

@end
