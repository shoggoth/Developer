//
//  IFInfoViewController.m
//  WOIAF
//
//  Created by Richard Henry on 19/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFInfoViewController.h"
#import "IFRootViewController.h"


@interface IFInfoViewController ()

@end

@implementation IFInfoViewController {
    
    BOOL                        iPhone;
    
    // State control
    enum { hidden, shown }      state;
    BOOL                        stateTransition;
    
    CGPoint                     infoViewShownCentre;
    CGPoint                     infoViewHiddenCentre;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Are we on an iPhone?
    iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);

    // Centres of view for animations
    infoViewShownCentre = self.view.center;
    infoViewHiddenCentre = CGPointMake(infoViewShownCentre.x, infoViewShownCentre.y - self.rootViewController.view.frame.size.height);
    self.view.center = infoViewHiddenCentre;
    backgroundButton.alpha = 0;
    backgroundButton.userInteractionEnabled = NO;
    state = hidden;
    
    
    NSURL       *htmlURL = [[NSBundle mainBundle] URLForResource:@"iPad_info_credits" withExtension:@"html"];
    NSURL       *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError     *error = nil;
    NSString    *html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    
    webView.scrollView.bounces = NO;
    
    [webView loadHTMLString:html baseURL:baseURL];
}

- (void)viewWillUnload {
    
    webView.delegate = nil;
    [webView stopLoading];
    webView = nil;
    
    [super viewWillUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

#pragma mark - Animation

- (void)hide:(id)sender {
    
    if (state == hidden || stateTransition) return;
    
    backgroundButton.alpha = 0;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         self.view.center = infoViewHiddenCentre;
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
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.view.center =  infoViewShownCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         backgroundButton.alpha = 0.5;
                         backgroundButton.userInteractionEnabled = YES;
                         state = shown;
                     }];
}

- (IBAction)tagButtonHit:(UIView *)sender {
    
    static NSString *htmlInfoNames[] = { @"", @"iPad_info_credits", @"iPad_info_FAQ's", @"iPad_info_FFGames" };
    
    
    NSURL       *htmlURL = [[NSBundle mainBundle] URLForResource:htmlInfoNames[sender.tag] withExtension:@"html"];
    NSURL       *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError     *error = nil;
    NSString    *html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    
    [webView loadHTMLString:html baseURL:baseURL];
}

#pragma mark - UIWebViewDelegate conformance

-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        
        return NO;
    }
    
    return YES;
}

@end
