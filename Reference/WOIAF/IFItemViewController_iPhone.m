//
//  IFItemViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFItemViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"
#import "IFMapViewController_iPhone.h"
#import "IFBookmarkViewController_iPhone.h"
#import "IFLockViewController_iPhone.h"

#import "IFPopoverBackgroundView.h"

#import "IFCoreDataStore.h"

#import "ItemBase.h"
#import "MapLocation.h"
#import "Map.h"
#import "Person.h"
#import "House.h"
#import "Place.h"
#import "Fact.h"


static inline NSString *replace_html_tags(const NSArray *facts, NSString *htmlTag, NSString *html, NSString *noDataString, NSString *preamble, NSString *postamble, NSString *separator) {
    
    NSUInteger factsCount = [facts count];
    
    if (factsCount) {
        
        NSString *factsString = @"";
        NSUInteger i = 0;
        
        for (Fact *fact in facts) {
            
            ++i;
            factsString = [factsString stringByAppendingString:[NSString stringWithFormat:@"%@%@", fact.html, (i < factsCount) ? separator : @""]];
        }
        
        html = [html stringByReplacingOccurrencesOfString:htmlTag withString:[NSString stringWithFormat:@"%@%@%@", preamble, factsString, postamble]];
        
    } else
        html = [html stringByReplacingOccurrencesOfString:htmlTag withString:noDataString];
    
    return html;
}

static inline NSString *replace_html_tag(Fact *fact, NSString *htmlTag, NSString *html, NSString *noDataString, NSString *preamble, NSString *postamble) {
    
    return [html stringByReplacingOccurrencesOfString:htmlTag withString:(fact) ? [NSString stringWithFormat:@"%@%@%@", preamble, fact.html, postamble]  : noDataString];
}

#pragma mark - Item view controller

@interface IFItemViewController_iPhone ()

- (void)loadDataForItem:(ItemBase *)item fromLastReadBook:(NSUInteger)lastReadBook withExtraProcessBlock:(NSString *(^)(NSString *html))extraBlock;

- (Fact *)latestFact:(NSSet *)facts fromLastReadBook:(NSUInteger)lastReadBook;
- (NSArray *)allFacts:(NSSet *)facts fromLastReadBook:(NSUInteger)lastReadBook;

- (void)selectHTMLTemplateForPerson:(Person *)person;
- (void)selectHTMLTemplateForPlace:(Place *)place;

@end

@implementation IFItemViewController_iPhone {
    
    // Subviews
    IFMapViewController_iPhone         *mapViewController;
    
    // Bookmark handling
    IFBookmarkViewController_iPhone    *bookmarkViewController;
    
    // Lock subview
    IFLockViewController_iPhone         *lockViewController;
    
    BOOL bookmarkViewShown;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up subviews
    [self initSubviews];
    
    webView.scrollView.bounces = NO;
    
    // Register for relevant notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyChangeNotification:) name:@"kIFItemAddedToHistory" object:[IFCoreDataStore defaultDataStore]];
    
    // Initial hide of map view
    //mapView.hidden = YES;
    //webView.hidden = YES;
    
    bookmarkViewShown = NO;
    
    [self showItem:self.currentItem];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    // Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Notifications

- (void)historyChangeNotification:(NSNotification *)note {
    
    NSLog(@"History change note %@", note);
    
    IFCoreDataStore *dataStore = note.object;
    
    // Alter history and bookmark controls
    backHistoryButton.enabled = ([dataStore historyBackCount]);
    forwardHistoryButton.enabled = ([dataStore historyForwardCount]);
}

#pragma mark - Subview handling

- (void)initSubviews {
    
    // Search view controller
    
    if (!mapViewController) {
        
        mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
        
        // Add the view as a subview if we haven't already
        if (mapViewController.view.superview != mapView) [mapView addSubview:mapViewController.view];
        
        mapViewController.view.center = mapView.center;
        
        mapViewController.rootViewController = self.rootViewController;
    }
    
    // Bookmark view controller
    if (!bookmarkViewController) {
        
        // Initialise but don't add as we'll be using this in a popover controller
        bookmarkViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"bookmark"];
        if (bookmarkViewController.view.superview != bookmarkView) [bookmarkView addSubview:bookmarkViewController.view];
        
        bookmarkViewController.view.center = bookmarkView.center;
        
        [bookmarkViewController loadSavedBookmarks];
        
        bookmarkViewController.rootViewController = self.rootViewController;
        bookmarkViewController.itemViewController = self;
    }
    
    // Lock view controller
    if (!lockViewController) {
        
        lockViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"lock"];
        lockViewController.rootViewController = self.rootViewController;
        
        // Add the view as a subview if we haven't already
        if (lockViewController.view.superview != self.view) [lockedView addSubview:lockViewController.view];
        
        lockViewController.view.center = lockedView.center;
    }
}

#pragma mark - Actions


#pragma mark Menu bar Actions

- (IBAction) returnToMainMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) starButtonTouched:(id)sender {
    ItemBase *currentItem = self.currentItem;
    
    if ([bookmarkViewController itemIsBookmarked:currentItem]) {
        [bookmarkViewController removeBookmarkForItem:currentItem];
        starButton.selected = NO;
    } else {
        [bookmarkViewController bookmarkItem:self.currentItem];
        starButton.selected = YES;
    }
    
    favouritesButton.enabled = [bookmarkViewController bookmarkCount];
}

- (IBAction) favouritesButtonTouched:(UIButton *)sender {
    
    if (bookmarkViewShown) {
        bookmarkView.hidden = YES;
    }else{
        [bookmarkViewController reloadBookmarks];
        bookmarkView.hidden = NO;
    }
    
    bookmarkViewShown = !bookmarkViewShown;
}

- (IBAction) backHistoryButtonTouched:(id)sender {
    ItemBase *item = [[IFCoreDataStore defaultDataStore] historyBack];
    [self.rootViewController itemSelected:item];
}

- (IBAction) forwardHistoryButtonTouched:(id)sender {
    ItemBase *item = [[IFCoreDataStore defaultDataStore] historyForward];
    [self.rootViewController itemSelected:item];
}

#pragma mark - Item loading

- (void)selectHTMLTemplateForPerson:(Person *)person {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"iphone_img/content/people/iphone_%@@2x", person.uid] withExtension:@"jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        person.htmlTemplate = @"iphone_personTemplateA";
    }else{
        person.htmlTemplate = @"iphone_personTemplateB";
    }
}

- (void)selectHTMLTemplateForPlace:(Place *)place {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"iphone_img/content/places/iphone_%@@2x", place.uid] withExtension:@"jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        place.htmlTemplate = @"iphone_placeTemplateA";
    }else{
        place.htmlTemplate = @"iphone_placeTemplateB";
    }
}

- (void)showItem:(id)item {
    
    self.currentItem = item;
    
    if ([item isKindOfClass:NSClassFromString(@"Map")]) {
        
        [mapViewController loadMap:item];
        
        mapView.hidden = NO;
        webView.hidden = YES;
        bookmarkView.hidden = YES;
        
        if (self.completionBlock) {
            
            self.completionBlock();
            self.completionBlock = nil;
        }
        
    } else {
        
        if (!mapView.hidden) webView.hidden = NO;
        
        mapView.hidden = YES;
        bookmarkView.hidden = YES;
        
        if ([item isKindOfClass:NSClassFromString(@"Person")]) {
            
            Person  *person = item;
            int     lastBookRead = [IFCoreDataStore defaultDataStore].lastBookRead;
            
            // MF - Change Templates as needed!
            [self selectHTMLTemplateForPerson:person];
            
            [self loadDataForItem:item fromLastReadBook:lastBookRead withExtraProcessBlock:^(NSString *html) {
                
                if (person.house.uid) {
                    
                    // Sigil
                    NSString *sigilString = [NSString stringWithFormat:@"<div id='sigil'><a href='got://woiaf.internal/house/%@'><img src='iphone_img/content/sigils/%@_sigil@2x.png' width='80' height='94' border='0' align='right' /></a></div>", person.house.uid, person.house.uid];
                    html = [html stringByReplacingOccurrencesOfString:@"@sigil" withString:sigilString];
                    
                    // House
                    NSString *houseString = [NSString stringWithFormat:@"<p><b>House:</b> %@</p> <p></p>", person.house.name];
                    html = [html stringByReplacingOccurrencesOfString:@"@house" withString:houseString];
                    
                } else {
                    
                    // Blank tags
                    html = [html stringByReplacingOccurrencesOfString:@"@sigil" withString:@""];
                    html = [html stringByReplacingOccurrencesOfString:@"@house" withString:@""];
                }
                
                // Insert character's title (latest)
                html = replace_html_tag([self latestFact:person.titles fromLastReadBook:lastBookRead], @"@titles", html, @"", @"<p><i>", @"</i></p>");
                // Insert character's aliases (latest)
                html = replace_html_tag([self latestFact:person.aliases fromLastReadBook:lastBookRead], @"@aliases", html, @"", @"<p><b>Aliases:</b> ", @"</p>");
                // Insert character's origin (latest)
                html = replace_html_tag([self latestFact:person.origin fromLastReadBook:lastBookRead], @"@origin", html, @"", @"<p><b>Origin:</b> ", @"</p>");
                // Insert character's place of birth (latest)
                html = replace_html_tag([self latestFact:person.placeOfBirth fromLastReadBook:lastBookRead], @"@placeOfBirth", html, @"", @"<p><b>Place of birth:</b> ", @"</p>");
                // Insert character's place of death (latest)
                html = replace_html_tag([self latestFact:person.placeOfDeath fromLastReadBook:lastBookRead], @"@placeOfDeath", html, @"", @"<p><b>Place of death:</b> ", @"</p>");
                // Insert character's parents (latest)
                html = replace_html_tag([self latestFact:person.parents fromLastReadBook:lastBookRead], @"@parents", html, @"", @"<p><b>Parents:</b> ", @"</p>");
                // Insert character's siblings (latest)
                html = replace_html_tag([self latestFact:person.siblings fromLastReadBook:lastBookRead], @"@siblings", html, @"", @"<p><b>Siblings:</b> ", @"</p>");
                // Insert character's children (latest)
                html = replace_html_tag([self latestFact:person.children fromLastReadBook:lastBookRead], @"@children", html, @"", @"<p><b>Children:</b> ", @"</p>");
                
                // Insert character's appearances (*)
                html = replace_html_tags([self allFacts:person.appearances fromLastReadBook:lastBookRead], @"@appearances", html, @"", @"<p><b>Appearances:</b> <i>", @"</i></p>", @", ");
                // Insert character's playedBy (*)
                html = replace_html_tags([self allFacts:person.playedBy fromLastReadBook:lastBookRead], @"@playedBy", html, @"", @"<p><b>Played by:</b> ", @"</p>", @", ");
                
                return html;
            }];
        }
        
        else if ([item isKindOfClass:NSClassFromString(@"House")]) {
            
            House  *house = item;
            int     lastBookRead = [IFCoreDataStore defaultDataStore].lastBookRead;
            
            house.htmlTemplate = @"iphone_houseTemplateA";
            
            [self loadDataForItem:item fromLastReadBook:lastBookRead withExtraProcessBlock:^(NSString *html) {
                
                // Replace house uid
                html = [html stringByReplacingOccurrencesOfString:@"@house_uid" withString:house.uid];
                
                return html;
            }];
        }
        
        else if ([item isKindOfClass:NSClassFromString(@"Place")]) {
            
            Place  *place = item;
            int     lastBookRead = [IFCoreDataStore defaultDataStore].lastBookRead;
            
            [self selectHTMLTemplateForPlace:item];
            
            [self loadDataForItem:item fromLastReadBook:lastBookRead withExtraProcessBlock:^(NSString *html) {
                
                if (place.type) {
                    // Sigil
                    NSString *typeString = [NSString stringWithFormat:@"<p><i>%@</i></p>", place.type];
                    html = [html stringByReplacingOccurrencesOfString:@"@type" withString:typeString];
                } else {
                    html = [html stringByReplacingOccurrencesOfString:@"@type" withString:@""];
                }
                
                NSSet   *filteredMapLocations = [place.mapLocations objectsPassingTest:^(MapLocation *mapLocation, BOOL *stop) { BOOL r = ([mapLocation.book intValue] <= lastBookRead); *stop = NO; return r; }];
                NSArray *sortedLocations = [filteredMapLocations sortedArrayUsingDescriptors:
                                            [NSArray arrayWithObjects:
                                             [NSSortDescriptor sortDescriptorWithKey:@"sortIndex" ascending:YES],
                                             nil]];
                
                // Insert place's map locations
                NSString *locationsString = @"";
                
                for (MapLocation *location in sortedLocations) locationsString = [locationsString stringByAppendingString:[NSString stringWithFormat:@"<a href='got://woiaf.internal/map/%@'><img src='iphone_img/content/map_icons/icon_%@@2x.png' width='110' /></a>", location.map.uid, location.map.uid]];
                
                html = [html stringByReplacingOccurrencesOfString:@"@map_locations" withString:locationsString];
                
                return html;
                
            }];
        }
        
        else {
            
            [self loadDataForItem:item fromLastReadBook:[IFCoreDataStore defaultDataStore].lastBookRead withExtraProcessBlock:nil];
        }
    }
    
    // Alter history and bookmark controls
    backHistoryButton.enabled = ([[IFCoreDataStore defaultDataStore] historyBackCount]);
    forwardHistoryButton.enabled = ([[IFCoreDataStore defaultDataStore] historyForwardCount]);
    
    favouritesButton.enabled = [bookmarkViewController bookmarkCount];
    starButton.selected = [bookmarkViewController itemIsBookmarked:item];
}

- (void)showItem:(id)item withCompletionBlock:(void (^)())cb {
    
    self.completionBlock = cb;
    
    [self showItem:item];
}

- (void)loadDataForItem:(ItemBase *)item fromLastReadBook:(NSUInteger)lastReadBook withExtraProcessBlock:(NSString *(^)(NSString *html))extraBlock {
    
    NSURL       *htmlURL = [[NSBundle mainBundle] URLForResource:item.htmlTemplate withExtension:@"html"];
    NSURL       *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSError     *error = nil;
    NSString    *html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
    
    // Replace person name and uid (all)
    html = [html stringByReplacingOccurrencesOfString:@"@name" withString:item.name];
    html = [html stringByReplacingOccurrencesOfString:@"@uid" withString:item.uid];
    
    // Insert item's facts (*)
    html = replace_html_tags([self allFacts:item.facts fromLastReadBook:lastReadBook], @"@facts", html, @"", @"", @"", @"");
    
    if (item.drawnBy) {
        
        // Artist credit
        NSString *artistCreditString = [NSString stringWithFormat:@"Illustration by: %@", item.drawnBy];
        html = [html stringByReplacingOccurrencesOfString:@"@drawnBy" withString:artistCreditString];
        
    } else html = [html stringByReplacingOccurrencesOfString:@"@drawnBy" withString:@""];
    
    if (extraBlock) html = extraBlock(html);
    
    [webView loadHTMLString:html baseURL:baseURL];
}

#pragma mark Fact processing

- (Fact *)latestFact:(NSSet *)facts fromLastReadBook:(NSUInteger)lastReadBook {
    
    NSArray     *sortedArray = [self allFacts:facts fromLastReadBook:lastReadBook];
    int         factCount = sortedArray.count;
    
    return (factCount) ? [sortedArray objectAtIndex:factCount - 1] : nil;
}

- (NSArray *)allFacts:(NSSet *)facts fromLastReadBook:(NSUInteger)lastReadBook {
    
    NSSet           *filteredFacts = [facts objectsPassingTest:^(Fact *fact, BOOL *stop) { BOOL r = ([fact.book intValue] <= lastReadBook); *stop = NO; return r; }];
    NSArray         *sortedArray = [filteredFacts sortedArrayUsingDescriptors:
                                    [NSArray arrayWithObjects:
                                     [NSSortDescriptor sortDescriptorWithKey:@"sortIndex" ascending:YES],
                                     nil]];
    
    return sortedArray;
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    BOOL shouldLoad = NO;
    
    if (navigationType == UIWebViewNavigationTypeOther) shouldLoad = YES;
    
    else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        NSURL    *requestedURL = request.URL;
        NSString *hostName = requestedURL.host;
        NSArray  *pathComponents = requestedURL.pathComponents;
        
        if ((pathComponents.count == 3) && ([hostName compare:@"woiaf.internal"] == NSOrderedSame)) {
            
            NSString *pathItemUID = pathComponents.lastObject;
            
            id item = [[IFCoreDataStore defaultDataStore] fetchItemWithUID:pathItemUID];
            if (item) {
                
                // Check that the link doesn't lead to a spoilered or locked item
                if (![lockViewController showItem:item]) {
                    
                    [[IFCoreDataStore defaultDataStore] addItemToHistory:item];
                    [self showItem:item];
                }

            } else NSLog(@"Can't follow web link to %@", pathItemUID);
            
            shouldLoad = YES;
        }
    }
    
    return shouldLoad;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    
    if (self.completionBlock) {
        
        self.completionBlock();
        self.completionBlock = nil;
    }
}

#pragma mark Utility


- (void)showWebView:(BOOL)show { webView.hidden = !show; }

- (void)hideBoomarkView {
    [self favouritesButtonTouched:nil];
}

@end
