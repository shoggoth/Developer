//
//  IDLensCompareViewController.m
//  iDispense
//
//  Created by Richard Henry on 20/05/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensCompareViewController.h"
#import "IDLensMaterialStore.h"
#import "IDGestureTransformer.h"
#import "IDLensRenderer.h"
#import "IDTrackball.h"

#import "DSEngine.h"
#import "DSMaths.h"

static GLKQuaternion savedRotation[2] = {{ 0, 0, 0, 1 }, { 0, 0, 0, 1 }};
static GLKVector3    savedPosition[2] = {{ 0, 0, -5 }, { 0, 0, -5 }};

@interface IDLensCompareViewController ()

// Subviews
@property (nonatomic, weak) IBOutlet IDMaterialSelectionView    *topSelectionView;
@property (nonatomic, weak) IBOutlet IDMaterialSelectionView    *bottomSelectionView;

@property (nonatomic, strong) IBOutlet UIView *compareView;

// Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *topMPVToBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *topMPVToTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *view1ToRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *view2ToLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *view3ToRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *view4toLeftConstraint;

// Rendering
@property (nonatomic, strong) IBOutlet IDLensRenderer       *renderer;

@end

@implementation IDLensCompareViewController  {

    // Update mechanics
    CADisplayLink           *displayLink;
    DSEngine                *engine;

    // Tap state
    NSInteger               activeTapViewTag;
    NSInteger               activeViewTag;

    // Navigation bar
    UIBarButtonItem         *viewChoiceButton;
    UIBarButtonItem         *leftRightButton, *leftButton, *rightButton;
    UIBarButtonItem         *topBottomButton, *topButton, *bottomButton;
}

+ (void)initialize {

//    // These are for the initial view with thickness
//    savedRotation[0] = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 0, 1, 0);
//    savedRotation[1] = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 0, 1, 0);
    savedRotation[0] = GLKQuaternionIdentity;
    savedRotation[1] = GLKQuaternionIdentity;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super initWithCoder:decoder]) {

        // Set up the engine
        engine = [DSEngine new];
        engine.context = [DSEngineContext new];
        engine.simulatorTickRate = 23 * kDSTimeToMilliseconds;
    }
    
    return self;
}

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    // Set up selection views
    self.topSelectionView.delegate = self;
    self.bottomSelectionView.delegate = self;

    [self.topSelectionView setup];
    [self.bottomSelectionView setup];

    // Tool bar buttons
    viewChoiceButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"View.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseViewAngle:)];
    leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LRBarButton_L.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseLensView:)];
    rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LRBarButton_R.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseLensView:)];
    topButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TBBarButton_T.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseLensView:)];
    bottomButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TBBarButton_B.png"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseLensView:)];

    self.navigationItem.rightBarButtonItems = @[ viewChoiceButton ];

    self.renderer.trackball.leftTransform.rot = savedRotation[0];
    self.renderer.trackball.leftTransform.pos = savedPosition[0];
    self.renderer.trackball.rightTransform.rot = savedRotation[1];
    self.renderer.trackball.rightTransform.pos = savedPosition[1];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self startRendering];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self stopRendering];

    // Save transforms
    savedRotation[0] = self.renderer.trackball.leftTransform.rot;
    savedPosition[0] = self.renderer.trackball.leftTransform.pos;
    savedRotation[1] = self.renderer.trackball.rightTransform.rot;
    savedPosition[1] = self.renderer.trackball.rightTransform.pos;
}

#pragma mark Action

- (void)resetSavedTransforms {

    //savedRotation[0] = savedRotation[1] = GLKQuaternionIdentity;
    savedRotation[0] = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 0, 1, 0);
    savedRotation[1] = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 0, 1, 0);
    savedPosition[0] = savedPosition[1] = (GLKVector3){ 0, 0, -5 };
}

- (void)chooseViewAngle:(UIButton *)barButton {

    static int      rotIndex;
    GLKQuaternion   lrot, rrot;

    // rotIndex++; rotIndex = rotIndex % 5;

    switch (rotIndex) {

        case 1:  // Outside edge view
            lrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 0, 1, 0);
            rrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 0, 1, 0);
            break;

        case 2:  // Inside edge view
            lrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 0, 1, 0);
            rrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 0, 1, 0);
            break;

        case 3:  // Top view
            lrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 1, 0, 0);
            rrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * +0.5, 1, 0, 0);
            break;

        case 4:  // Bottom view
            lrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 1, 0, 0);
            rrot = GLKQuaternionMakeWithAngleAndAxis(M_PI * -0.5, 1, 0, 0);
            break;

        default: lrot = rrot = GLKQuaternionIdentity; break;    // Front view
    }

    self.renderer.trackball.leftTransform.rot = lrot;
    self.renderer.trackball.rightTransform.rot = rrot;

    self.renderer.trackball.leftTransform.pos = self.renderer.trackball.rightTransform.pos = (GLKVector3) { 0, 0, -5 };
}

- (void)chooseLensView:(UIBarButtonItem *)barButton {

    static NSInteger leftRightTargets[] = { 2, 1, 4, 3 };
    static NSInteger topBottomTargets[] = { 3, 4, 1, 2 };
    NSInteger targetViewTag = (barButton == leftRightButton) ? leftRightTargets[activeViewTag - 1] : topBottomTargets[activeViewTag - 1];

    [self resetLensViews];
    [self switchToLensView:targetViewTag animated:NO];
    activeTapViewTag = activeViewTag = targetViewTag;
    [self adjustButtonsForActiveViewTag];
}

#pragma mark Lens view switching

- (void)resetLensViews {

    activeTapViewTag = activeViewTag = 0;

    self.renderer.trackball.viewToTrack = 0;

    if (self.topSelectionView.collapsed) [self.topSelectionView setCollapsedState:NO animated:NO];
    if (self.bottomSelectionView.collapsed) [self.bottomSelectionView setCollapsedState:NO animated:NO];

    self.view1ToRightConstraint.priority = UILayoutPriorityDefaultLow;
    self.view2ToLeftConstraint.priority = UILayoutPriorityDefaultLow;
    self.view3ToRightConstraint.priority = UILayoutPriorityDefaultLow;
    self.view4toLeftConstraint.priority = UILayoutPriorityDefaultLow;

    self.topMPVToTopConstraint.priority = UILayoutPriorityDefaultLow;
    self.topMPVToBottomConstraint.priority = UILayoutPriorityDefaultLow;
}

- (NSInteger)switchToLensView:(const NSInteger)viewTag animated:(BOOL)animated {

    NSInteger avt = 0;

    const BOOL topCollapsed = self.topSelectionView.collapsed;
    const BOOL bottomCollapsed = self.bottomSelectionView.collapsed;
    
    // Handle the tap depending on which view was tapped
    switch (viewTag) {
            
        case 1:
        case 2: {
            NSLayoutConstraint *constraint =  (viewTag == 1) ? self.view1ToRightConstraint : self.view2ToLeftConstraint;
            UILayoutPriority priority = (bottomCollapsed) ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh;
            
            self.topMPVToBottomConstraint.priority = priority;
            constraint.priority = priority;
            [self.bottomSelectionView setCollapsedState:!bottomCollapsed animated:animated];

            if (!bottomCollapsed) avt = viewTag;
        } break;
            
        case 3:
        case 4: {
            NSLayoutConstraint *constraint =  (viewTag == 3) ? self.view3ToRightConstraint : self.view4toLeftConstraint;
            UILayoutPriority priority = (topCollapsed) ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh;
            
            self.topMPVToTopConstraint.priority = priority;
            constraint.priority = priority;
            [self.topSelectionView setCollapsedState:!topCollapsed animated:animated];

            if (!topCollapsed) avt = viewTag;
        } break;
    }

    // Set tracking
    self.renderer.trackball.viewToTrack = avt;

    return avt;
}

- (void)adjustButtonsForActiveViewTag {

    if (!activeViewTag) self.navigationItem.rightBarButtonItems = @[ viewChoiceButton ];

    else {

        leftRightButton = (activeViewTag % 2) ? leftButton : rightButton;
        topBottomButton = (activeViewTag > 2) ? bottomButton : topButton;
        self.navigationItem.rightBarButtonItems = @[ viewChoiceButton, leftRightButton, topBottomButton ];
    }
}

- (void)showCompareView {

    // Show the welcome instruction screen if it has been allowed in the settings
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"show_welcome_screen_preference"] boolValue]) {

        // Load  the welcome screen from the nib file.
        [[UINib nibWithNibName:@"IDCompareViewControls" bundle:nil] instantiateWithOwner:self options:nil];

        // Make sure that we are using autolayout and that translated constraints do not cause a conflict
        self.compareView.translatesAutoresizingMaskIntoConstraints = NO;

        // Prepare the dictionary for visual constraint manipulation.
        NSDictionary *viewsDictionary = @{ @"topLayoutGuide" : self.topLayoutGuide, @"containerView" : self.view, @"instructionView" : self.compareView };
        NSDictionary *metricsDictionary = @{ @"space" : @8 };

        // Add the subview we got from the nib file.
        [self.view addSubview:self.compareView];

        // Add the constraints
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-(space)-[instructionView(100)]" options:0 metrics:metricsDictionary views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(space)-[instructionView]-(space)-|" options:0 metrics:metricsDictionary views:viewsDictionary]];
    }
}

#pragma mark Gesture recognition

- (IBAction)lensViewTapped:(UITapGestureRecognizer *)tap {

    // Ignore taps in multiple views. Only the first recognised tap will count.
    if (!activeTapViewTag) activeTapViewTag = tap.view.tag;
    else if (activeTapViewTag == tap.view.tag) activeTapViewTag = 0;
    else return;

    // View tracking
    activeViewTag = [self switchToLensView:tap.view.tag animated:YES];

    [self adjustButtonsForActiveViewTag];

    return;
}

#pragma mark Rendering

- (void)startRendering {

    if (!displayLink) {

        NSInteger frameInterval = 1;

        // Create display link
        displayLink = [CADisplayLink displayLinkWithTarget:self.view selector:@selector(render:)];
        [displayLink setFrameInterval:frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopRendering {

    if (displayLink) {

        [displayLink invalidate];

        displayLink = nil;
    }
}

#pragma mark DSViewDelegate conformance

- (void)view:(DSView *)view willPrepareDrawContext:(DSDrawContext *)drawContext {

    // Make sure that a depth buffer is allocated.
    view.depthBuffer = YES;

    // Set up renderer
    self.renderer.context = drawContext;
    engine.renderer = self.renderer;
}

- (BOOL)view:(DSView *)view didPrepareDrawContext:(DSDrawContext *)drawContext {

    // Set up the draw context
    drawContext.depthTest = YES;
    drawContext.autoSetNormalMatrix = YES;
    drawContext.culling = kDSCullBackFaces;

    // Renderer post draw context setup
    [self.renderer setupWithLeftLensParams:self.leftLensParameters rightLensParams:self.rightLensParameters];

    return YES;
}

- (void)view:(DSView *)view willRenderToContext:(DSDrawContext *)drawContext {

    // Give the engine a tick
    [engine tick];

    // The engine has now finished drawing so let's flush out the draw context.
    [drawContext flush];
}

#pragma mark IDMaterialSelectDelegate conformance

- (void)materialPicker:(DSHorizontalPickerView *)picker didPickMaterialWithFilterIndex:(NSInteger)filterIndex index:(NSInteger)index {

    IDLensMaterial material = [[IDLensMaterialStore defaultLensMaterialStore] materialForFilterIndex:filterIndex index:index];

    if (picker.tag == 1)
        self.renderer.topMaterial = material;
    else
        self.renderer.bottomMaterial = material;
}

@end

