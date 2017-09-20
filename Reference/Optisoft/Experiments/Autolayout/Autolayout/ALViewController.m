//
//  ALViewController.m
//  Autolayout
//
//  Created by Optisoft Ltd on 11/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "ALViewController.h"
#import "ALSingleView.h"


@interface ALViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vsConstraint;

@end

@implementation ALViewController {
    
    NSMutableSet        *recycledSubViews;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Expand the text from what was initially in the UI.
    self.firstLabel.text = @"This is the first label and it is aligned to the bottom of the containing view";
    self.secondLabel.text = @"Second label (top)";
    
    // Handle the scroll view
    self.scrollView.delegate = self;
    
    // Set up recycling of the sub views
    recycledSubViews = [NSMutableSet set];
}

- (void)dealloc {
    
    recycledSubViews = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //self.scrollView.contentSize = CGSizeMake(1024, 1024);

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)AddSubView:(id)sender {
    
    const float f = 136;
    static int  i;
    
    static CGPoint placePoint = (const CGPoint) { f, f };
    
    ALSingleView *subView;
    
    if (recycledSubViews.count) {
        
        subView = [recycledSubViews anyObject];
        
        [recycledSubViews removeObject:subView];
    
    } else subView = [[[NSBundle mainBundle] loadNibNamed:@"ALSingleView" owner:self options:nil] objectAtIndex:0];
    
    subView.tag = 31337;
    
    // Place the subview within the content view
    subView.center = placePoint;
    
    if (++i % 3) placePoint.x += f * 2; else { placePoint.x = f; placePoint.y += f * 2; }
    
    [self.contentView addSubview:subView];
    
    // Resize the scroll view
    self.scrollView.contentSize = CGSizeMake(placePoint.x, placePoint.y - f);
}

- (IBAction)embiggenSubView:(UIButton *)sender {
    
    sender.superview.backgroundColor = [UIColor redColor];
    
    NSLog(@"Want to embiggen %@", sender.superview);
}

- (IBAction)adjustLabels:(id)sender {

    static unsigned foo;

    self.secondLabel.text = [NSString stringWithFormat:@"%@ add %d", self.secondLabel.text, ++foo];
}

- (IBAction)resetLabels:(id)sender {
    
    self.secondLabel.text = @"Nowt";
    
    NSLog(@"Constraint = %@", self.vsConstraint);
}

#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView { NSLog(@"SV scrolled"); }

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return [scrollView.subviews objectAtIndex:0];
}

@end
