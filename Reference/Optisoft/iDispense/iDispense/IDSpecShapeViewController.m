//
//  IDSpecShapeViewController.m
//  iDispense
//
//  Created by Richard Henry on 09/12/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "IDSpecShapeViewController.h"
#import "IDSpecShape.h"


@implementation IDSpecShapeViewController {

    NSMutableArray      *specShapes;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {

    if ((self = [super initWithStyle:style])) {

        // Initialisation code
        [self setup];
    }

    return self;
}

- (void)awakeFromNib {

    [super awakeFromNib];
    
    // Initialisation code
    [self setup];
}

- (void)setup {

    specShapes = [NSMutableArray array];
    
    [specShapes addObject:[[IDSpecShape alloc] initWithImage:[UIImage imageNamed:@"RoundFrames.png"] name:@"Round Frames"]];
    [specShapes addObject:[[IDSpecShape alloc] initWithImage:[UIImage imageNamed:@"Groucho.png"] name:@"Groucho"]];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource conformance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return specShapes.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    IDSpecShape *specShape = [specShapes objectAtIndex:indexPath.row];
    cell.textLabel.text = specShape.name;

    return cell;
}

#pragma mark UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    IDSpecShape *specShape = [specShapes objectAtIndex:indexPath.row];

    [self.delegate didPickFrameShape:specShape.image];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
