//
//  ViewController.m
//  PhotoView
//
//  Created by Dan Tan on 4/4/14.
//  Copyright (c) 2014 Dan Tan. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
@property (retain, nonatomic)  NSMutableArray *arrayGroup;
@property (nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (id)arrayGroup
{
    if (nil == _arrayGroup) {
        _arrayGroup = [[NSMutableArray alloc] init];
    }
    return _arrayGroup;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    
    // search photos
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        void (^assetsEnumerationBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (nil == group) {
                return;
            }
            NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            if (ALAssetsGroupSavedPhotos == nType){
                [self.arrayGroup insertObject:group atIndex:0];
            }
            else{
                [self.arrayGroup addObject:group];
            }
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        };
        void(^assetsFailureBlock)(NSError*) = ^(NSError *error)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            NSLog(@"A problem occured %@", [error description]);
        };
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetsEnumerationBlock failureBlock:assetsFailureBlock];
    });

}

-(void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_tableView release];
    [_arrayGroup release];
    [super dealloc];
}

#pragma mark TableView dateSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayGroup count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    ALAssetsGroup *group = [self.arrayGroup objectAtIndex:[indexPath row]];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger count = [group numberOfAssets];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%ld)", [group valueForProperty:ALAssetsGroupPropertyName], (long)count]];
    [cell.imageView  setImage:[UIImage imageWithCGImage:[group posterImage]]];

    return cell;
}

#pragma mark segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"showAlbum"]) {
    }
}

@end
