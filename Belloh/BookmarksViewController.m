//
//  BookmarksViewController.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "BookmarksViewController.h"
#import "UIColor+App.h"

@interface BookmarksViewController ()

@property (nonatomic) NSArray *bookmarks;

@end

@implementation BookmarksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.navBar respondsToSelector:@selector(barTintColor)]) {
        // iOS7
        self.navBar.barTintColor = [UIColor mainColor];
    }
    else {
        // older
        self.navBar.tintColor = [UIColor mainColor];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.bookmarks = [defaults objectForKey:@"bookmarks"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)doneEditing:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.bookmarks forKey:@"bookmarks"];
    [defaults synchronize];
    
    [self.tableView setEditing:NO animated:YES];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    [self.navBar.topItem setRightBarButtonItem:item animated:YES];
}

#pragma mark - IBActions

- (IBAction)edit:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
    [self.navBar.topItem setRightBarButtonItem:item animated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellIdentifier = @"BookmarkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *bookmark = self.bookmarks[indexPath.row];
    cell.textLabel.text = bookmark[@"name"];
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(bookmarksViewController:didSelectBookmark:)]) {
        NSDictionary *bookmark = self.bookmarks[indexPath.row];
        [self.delegate bookmarksViewController:self didSelectBookmark:bookmark];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *temp = [self.bookmarks mutableCopy];
    [temp removeObjectAtIndex:indexPath.row];
    self.bookmarks = temp;
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

@end
