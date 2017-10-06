//
//  IDSpecShapeViewController.h
//  iDispense
//
//  Created by Richard Henry on 09/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


//
//  protocol IDSpecShapePickerDelegate
//
//  Used to inform the delegate that a spec. shape has been picked from the popover.
//

@protocol IDSpecShapePickerDelegate <NSObject>

- (void)didPickFrameShape:(UIImage *)frameShape;

@end


//
//  interface IDSpecShapeViewController
//
//  Presents a table of available spec. shapes to the user.
//

@interface IDSpecShapeViewController : UITableViewController

@property(nonatomic, weak) id <IDSpecShapePickerDelegate> delegate;

@end
