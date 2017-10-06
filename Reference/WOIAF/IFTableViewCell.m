//
//  IFTableCellViewCell.m
//  WOIAF
//
//  Created by Simon Hardie on 16/08/2012.
//
//

#import "IFTableViewCell.h"
#import "IFCoreDataStore.h"

#import "Person.h"
#import "House.h"
#import "Place.h"
#import "Map.h"


UIImage *getDefaultThumbImageForItem(ItemBase *itemBase) {
    
    NSString *thumbImageName;
    
    if ([itemBase isKindOfClass:[House class]]) thumbImageName = @"default_house_tumbnail.png";
    
    else if ([itemBase isKindOfClass:[Place class]]) thumbImageName = @"default_place_tumbnail.png";
    
    else if ([itemBase isKindOfClass:[Map class]]) thumbImageName = @"default_map_tumbnail.png";
    
    else if ([itemBase isKindOfClass:[Person class]]) {
        
        if ([((Person *)itemBase).type caseInsensitiveCompare:@"female"] == NSOrderedSame) thumbImageName = @"default_female_tumbnail.png";
        else  thumbImageName = @"default_male_tumbnail.png";
    }
    
    return [UIImage imageNamed:thumbImageName];
}


@interface IFTableViewCell ()

- (void)setupCell;

@end

@implementation IFTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        
        [self setupCell];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        [self setupCell];
    }
    
    return self;
}

- (void)setupCell {
    
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont fontWithName: @"TrajanPro-Bold" size:18];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (highlighted) NSLog(@"Cell %@ is highlighted", self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    // Reset the selection immediately
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    //backgroundImageView.image = [UIImage imageNamed:(selected) ? @"listbackground_3.png" : @"listbackground_2.png"];
    //((UIImageView *)self.backgroundView).highlighted = selected;
}

- (NSString *)imageName {
    
    return [NSString stringWithFormat:@"listbackground_%d.png", self.tag];
}

// MF - Added
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, 58);
    
    // Resize the text label
    CGRect textLabelFrameRect = self.textLabel.frame;
    textLabelFrameRect.origin.x = 74;
    textLabelFrameRect.origin.y += 3;
    textLabelFrameRect.size.width = 200;
    self.textLabel.frame = textLabelFrameRect;
    
    // Truncate the text
    [self.textLabel setLineBreakMode:NSLineBreakByTruncatingTail];
}

@end
