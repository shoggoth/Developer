//
//  IDSettingsViewController.m
//  iDispense
//
//  Created by Richard Henry on 25/02/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDSettingsViewController.h"
#import "IDDispensingDataStore.h"
#import "IDContextWatcher.h"
#import "IDImageStore.h"
#import "IDInAppPurchases.h"
#import "UIImage+ImageUtils.h"

#import "iDispense-Swift.h"

@interface IDSettingsViewController ()

@property(nonatomic, strong) UIPopoverController *popover;
@property(nonatomic, strong) NSURL *pickedImageURL;

@end

@implementation IDSettingsViewController {

    // Purchases
    __weak IBOutlet UIButton                            *fullVersionUpgradeButton;
    __weak IBOutlet UIButton                            *restorePurchasesButton;

    // Details
    __strong IBOutletCollection(UITextField) NSArray    *optometristDetails;
    __weak IBOutlet UITextField                         *contactNameTextField;
    __weak IBOutlet UITextField                         *contactInitialsTextField;

    // iCloud
    __weak IBOutlet UISwitch                            *enableMultiUserSwitch;
    __weak IBOutlet UILabel                             *enableMultiUserLabel;

    // Watermark controls
    __weak IBOutlet UIImageView                         *optometristLogoImageView;
    __weak IBOutlet UIView                              *optometristLogoBackgroundView;
    __weak IBOutlet UISlider                            *imageAlphaSlider;
    __weak IBOutlet UISwitch                            *watermarkSwitch;

    // Image settings
    __weak IBOutlet UISlider                            *imageQualitySlider;
    __weak IBOutlet UILabel                             *imageQualityLabel;
    __weak IBOutlet UISegmentedControl                  *imageSizeSegControl;

    // SDC Settings
    __weak IBOutlet UISwitch                            *sdcSwitch;

    // Lens render settings
    __weak IBOutlet UISwitch                            *meridianSwitch;

    // Purchase button mods
    void (^decorateButton)(UIButton *);

    // Database
    IDDispensingDataStore                               *dataStore;

    // Practice details sync
    IDContextWatcher                                    *practiceDetailsWatcher;
    BOOL                                                practiceDetailsChanged;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if ((self = [super initWithCoder:aDecoder])) {

        // Initialisation
        decorateButton = ^void(UIButton *button) {

            button.layer.borderWidth = 0.8;
            button.layer.borderColor = (button.enabled) ? [UIColor redColor].CGColor : [UIColor lightGrayColor].CGColor;
            button.layer.cornerRadius = 5;
        };
    }

    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    dataStore = [IDDispensingDataStore defaultDataStore];

    // Set up purchase buttons
    [self setupPurchaseRelatedButtons];

    // Set up purchase notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseTookPlace:) name:IDIAPProductPurchasedNotification object:nil];

    // Set up optometrist's logo
    optometristLogoImageView.image = [[IDImageStore defaultImageStore] optometristLogo];

    // Set up image quality parameters
    const float imageQuality = [[NSUserDefaults standardUserDefaults] floatForKey:@"jpeg_image_quality_preference"];
    imageQualitySlider.value = imageQuality;
    imageQualityLabel.text = [NSString stringWithFormat:@"%.2f", imageQuality];

    // Image view background setup
    optometristLogoBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"EmptyBackground.png"]];
    optometristLogoImageView.opaque = NO;
    optometristLogoImageView.layer.opaque = NO;

    // Control alpha setup
    const float alpha = [[NSUserDefaults standardUserDefaults] floatForKey:@"optometrist_logo_alpha_preference"];
    optometristLogoImageView.alpha = alpha;
    imageAlphaSlider.value = alpha;

    // Watermarking setup
    watermarkSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"optometrist_watermark_preference"];
    [self adjustImageViewsForWatermarkingState:watermarkSwitch.on];

    // Set up size segmented control
    imageSizeSegControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"share_image_canvas_size_preference"];

    // Sync setup
    enableMultiUserSwitch.enabled = [IDInAppPurchases sharedIAPStore].multiUserUnlocked;

    // Compare setup
    meridianSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"show_lens_meridian_preference"] boolValue];

    // SDC setup
    sdcSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"sdc_active"];

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Get practice details from the database.
    [self setupPracticeDetailFields];

    // This state might well change between appearances of the settings.
    [enableMultiUserSwitch setOn:dataStore.usingSync animated:animated];
}

- (void)setupPracticeDetailFields {

    NSDictionary *practiceDetails = dataStore.practiceDetails;

    // Set up optometrist's details
    for (UITextField *tf in optometristDetails) {

        switch (tf.tag) {

            case 0: tf.text = [practiceDetails objectForKey:@"practiceName"]; break;
            case 2: tf.text = [practiceDetails objectForKey:@"telephoneNumber"]; break;
            case 3: tf.text = [practiceDetails objectForKey:@"address1"]; break;
            case 4: tf.text = [practiceDetails objectForKey:@"address2"]; break;
            case 5: tf.text = [practiceDetails objectForKey:@"postCode"]; break;
        }
    }

    // Set up contact details
    contactNameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"optometrist_contact_name_preference"];
    contactInitialsTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"optometrist_contact_initials_preference"];

    practiceDetailsChanged = NO;
}

#pragma mark Dis/Appear

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    // Save contents of the optometrist details fields.
    if (practiceDetailsChanged) {

        NSMutableDictionary *pd = [NSMutableDictionary dictionary];

        for (UITextField *tf in optometristDetails) {

            NSString *text = tf.text;

            switch (tf.tag) {

                case 0: [pd setObject:text forKey:@"practiceName"]; break;
                //case 1: [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"optometrist_contact_name_preference"]; break;
                case 2: [pd setObject:text forKey:@"telephoneNumber"]; break;
                case 3: [pd setObject:text forKey:@"address1"]; break;
                case 4: [pd setObject:text forKey:@"address2"]; break;
                case 5: [pd setObject:text forKey:@"postCode"]; break;
                //case 6: [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"optometrist_contact_initials_preference"]; break;
            }
        }

        // Update the modified date of the practice details for de-duplication.
        [dataStore setPracticeDetails:pd];

        // Save the practice details
        [dataStore save];

        practiceDetailsChanged = NO;
    }

    // Save contact details (always)
    [[NSUserDefaults standardUserDefaults] setObject:contactNameTextField.text forKey:@"optometrist_contact_name_preference"];
    [[NSUserDefaults standardUserDefaults] setObject:contactInitialsTextField.text forKey:@"optometrist_contact_initials_preference"];
}

#pragma mark UI adjustments

- (void)adjustImageViewsForWatermarkingState:(BOOL)wState {

    optometristLogoImageView.hidden = !wState;
    imageAlphaSlider.enabled = wState;
}

- (void)setupPurchaseRelatedButtons {

    // Set up purchase controls
    decorateButton(fullVersionUpgradeButton);

    // Multi user controls
    BOOL multiUserPurchased = [IDInAppPurchases sharedIAPStore].multiUserUnlocked;

    enableMultiUserSwitch.enabled = multiUserPurchased;
    enableMultiUserLabel.enabled = multiUserPurchased;
}

#pragma mark Actions

- (IBAction)chooseImage:(UIView *)sender {

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {

        UIImagePickerController *picker= [UIImagePickerController new];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        // Use a popover controller if we're on an iPad device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

            self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.popover.delegate = self;

            [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else [self presentViewController:picker animated:YES completion:^{}];
    }
}

- (IBAction)lensMeridianPicked:(UISwitch *)ms {

    [[NSUserDefaults standardUserDefaults] setObject:@(ms.on) forKey:@"show_lens_meridian_preference"];
}

- (IBAction)purchaseButtonPressed:(UIButton *)sender {

    if (sender.tag == 2) {

        [[IDInAppPurchases sharedIAPStore] restorePurchases];

    } else {

        IDPurchaseViewController *picker = [[IDPurchaseViewController alloc] initWithNibName:@"IDPurchaseViewController" bundle:nil];

        picker.preferredContentSize = picker.view.frame.size;

        // Use a popover controller if we're on an iPad device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

            self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.popover.delegate = self;

            [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else [self presentViewController:picker animated:YES completion:^{}];
    }
}

- (IBAction)watermarkPicked:(UISwitch *)ws {

    [self adjustImageViewsForWatermarkingState:ws.on];

    [[NSUserDefaults standardUserDefaults] setObject:@(ws.on) forKey:@"optometrist_watermark_preference"];
}

- (IBAction)alphaValueChanged:(UISlider *)slider {

    optometristLogoImageView.alpha = slider.value;
}

- (IBAction)alphaValuePicked:(UISlider *)slider {

    [[NSUserDefaults standardUserDefaults] setObject:@(slider.value) forKey:@"optometrist_logo_alpha_preference"];
}

- (IBAction)imageQualityChanged:(UISlider *)slider {

    imageQualityLabel.text = [NSString stringWithFormat:@"%.2f", slider.value];
}

- (IBAction)imageQualityPicked:(UISlider *)slider {

    [[NSUserDefaults standardUserDefaults] setObject:@(slider.value) forKey:@"jpeg_image_quality_preference"];
}

- (IBAction)imageSizePicked:(UISegmentedControl *)segControl {

    [[NSUserDefaults standardUserDefaults] setObject:@(segControl.selectedSegmentIndex) forKey:@"share_image_canvas_size_preference"];
}

- (IBAction)enableMultiUser:(UISwitch *)multiUserSwitch {

    BOOL on = multiUserSwitch.on;
    NSString *title = on ? @"Enable multi user" : @"Disable multi user";
    NSString *message = on ? @"Merge local data from iPad to the Cloud for multi-user sync?\nImportant: Please insert different initials (Order Suffix) in the Contact Details section below on each iPad to be used, to ensure order identifiers are unique." : @"Do you want to disable multi user functions and use a local database instead?";

    [self presentViewController:({

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            // The user has cancelled the switching on or off of the cloud so reset the switch to indicate that.
            [multiUserSwitch setOn:!on animated:YES];
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

            // Set iCloud sync status.
            dataStore.usingSync = on;

            // Present warning
            if (on) {

                // Warn the user
                [self presentViewController:({

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please Note" message:@"Due to iCloud technology, synchronisation between iPads may be delayed by approximately 10 seconds." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];

                    alert; }) animated:YES completion:nil];
            }
        }]];

        alert; }) animated:YES completion:nil];
}

- (IBAction)enableSDC:(UISwitch *)sw {

    [[NSUserDefaults standardUserDefaults] setObject:@(sw.on) forKey:@"sdc_active"];
}

- (IBAction)practiceDetailsChanged:(UITextField *)textField {

    practiceDetailsChanged = YES;
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"editLensMatrix"]) {

        SDCTableViewController *sdcTableViewController = segue.destinationViewController;

        sdcTableViewController.navigationItem.title = @"Edit Lens Matrix";
        sdcTableViewController.editingLensMatrix = YES;

    } else if ([segue.identifier isEqualToString:@"editFrameMatrix"]) {

        SDCTableViewController *sdcTableViewController = segue.destinationViewController;

        sdcTableViewController.navigationItem.title = @"Edit Frame Matrix";
        sdcTableViewController.editingLensMatrix = NO;
    }
}

#pragma mark Notifications

- (void)purchaseTookPlace:(NSNotification *)note {

    [self setupPurchaseRelatedButtons];
}

#pragma mark <UITextfieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];

    return NO;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (textField.tag != 6) return YES;

    const NSUInteger kMaxLength = 3;

    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;

    NSUInteger newLength = oldLength - rangeLength + replacementLength;

    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;

    return newLength <= kMaxLength || returnKey;
}

#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    self.pickedImageURL = [info objectForKey:UIImagePickerControllerReferenceURL];

    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *thumbImage = [pickedImage imageScaledAndCroppedToSize:optometristLogoImageView.bounds.size];

    optometristLogoImageView.image = thumbImage;

    [[IDImageStore defaultImageStore] getImageAssetAtURL:self.pickedImageURL withCompletionBlock:^(UIImage *image) {

        [[IDImageStore defaultImageStore] setOptometristLogo:thumbImage];
    }];

    [self.popover dismissPopoverAnimated:YES];
}

@end
