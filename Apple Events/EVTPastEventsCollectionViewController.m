//
//  EVTPastEventsCollectionViewController.m
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTPastEventsCollectionViewController.h"

#import "EVTEvent.h"
#import "EVTEventCollectionViewItem.h"
#import "EVTEventsViewController.h"

#define kViewHeight 260.0

@import EventsUI;

@interface EVTPastEventsCollectionViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;

@property (readonly) EVTEventsViewController *mainController;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation EVTPastEventsCollectionViewController

+ (instancetype)instantiateWithStoryboard:(NSStoryboard *)storyboard
{
    return [storyboard instantiateControllerWithIdentifier:NSStringFromClass([self class])];
}

- (EVTEventsViewController *)mainController
{
    return (EVTEventsViewController *)self.parentViewController;
}

- (void)setEvents:(NSArray<EVTEvent *> *)events
{
    _events = [events copy];
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightConstraint = [self.view.heightAnchor constraintEqualToConstant:kViewHeight];
    [self.heightConstraint setActive:YES];
    
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.scrollDirection = NSCollectionViewScrollDirectionHorizontal;
    layout.itemSize = NSMakeSize(220.0, 220.0);
    layout.minimumInteritemSpacing = 22.0;
    layout.sectionInset = NSEdgeInsetsMake(0, 2.0, 0, 2.0);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.selectable = YES;
    
    [self.collectionView registerClass:[EVTEventCollectionViewItem class] forItemWithIdentifier:@"event"];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.events.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    EVTEventCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"event" forIndexPath:indexPath];
    
    item.imageFetcher = self.imageFetcher;
    item.event = self.events[indexPath.item];
    
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    if (indexPaths.count <= 0) return;
    
    [self.mainController showEvent:self.events[indexPaths.anyObject.item]];
}

- (void)deactivateConstraintsAffectingWindow
{
    self.heightConstraint.constant = 0;
}

- (void)reactivateConstraintsAffectingWindow
{
    self.heightConstraint.animator.constant = kViewHeight;
}

@end
