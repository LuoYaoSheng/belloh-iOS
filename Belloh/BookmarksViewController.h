//
//  BookmarksViewController.h
//  Belloh
//
//  Created by Eric Webster on 2014-07-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarksViewController;

@protocol BookmarksViewControllerDelegate <NSObject>

@optional
- (void)bookmarksViewController:(BookmarksViewController *)bookmarksViewController didSelectBookmark:(NSDictionary *)bookmark;

@end

@interface BookmarksViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<BookmarksViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;

- (IBAction)edit:(id)sender;
- (IBAction)cancel:(id)sender;

@end
