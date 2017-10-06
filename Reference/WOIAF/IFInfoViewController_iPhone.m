//
//  IFInfoViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFInfoViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"

@interface IFInfoViewController_iPhone ()

@end

@implementation IFInfoViewController_iPhone {
    
    // State control
    enum { hidden, shown }      state;
    BOOL                        stateTransition;
    
    CGPoint                     infoViewShownCentre;
    CGPoint                     infoViewHiddenCentre;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //const CGRect thisViewFrame = self.view.frame;
    //const CGRect rootViewFrame = self.rootViewController.view.frame;
    //const float  xCentre = rootViewFrame.size.width * 0.5 - thisViewFrame.size.width * 0.5;
    
    // Centre our view in the superview's frame
    infoViewShownCentre = self.view.center;
    infoViewHiddenCentre = CGPointMake(infoViewShownCentre.x, infoViewShownCentre.y - 1000.0f);
    
    self.view.center = infoViewHiddenCentre;
    
    //backgroundButton.alpha = 0;
    backgroundButton.userInteractionEnabled = NO;
    
    state = shown;
    
    NSURL       *htmlURL = [[NSBundle mainBundle] URLForResource:@"iphone_info_credits" withExtension:@"html"];
    NSURL       *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError     *error = nil;
    NSString    *html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    
    [webView loadHTMLString:html baseURL:baseURL];
    
    webView.scrollView.bounces = NO;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Animation

- (void) initialHide {
    self.view.superview.center = CGPointMake(self.view.superview.center.x, infoViewHiddenCentre.y);
    
    state = hidden;
}

- (void)hide:(id)sender {
    
    if (state == hidden || stateTransition) return;
    
    backgroundButton.alpha = 0;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         self.view.superview.center = infoViewHiddenCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         backgroundButton.userInteractionEnabled = NO;
                         state = hidden;
                     }];
}

- (void)show:(id)sender {
    
    if (state == shown || stateTransition) return;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         self.view.superview.center =  infoViewShownCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         //backgroundButton.alpha = 0.5;
                         backgroundButton.userInteractionEnabled = YES;
                         state = shown;
                     }];
}

- (IBAction)tagButtonHit:(UIView *)sender {
    
    NSLog(@"Tag = %d", sender.tag);
    static NSString *htmlInfoNames[] = { @"", @"iphone_info_credits", @"iphone_info_FAQ", @"iphone_info_FFGames" };
    
    
    NSURL       *htmlURL = [[NSBundle mainBundle] URLForResource:htmlInfoNames[sender.tag] withExtension:@"html"];
    NSURL       *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError     *error = nil;
    NSString    *html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    
    [webView loadHTMLString:html baseURL:baseURL];
}

#pragma mark - UIWebViewDelegate conformance

-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}
@end

