//
//  EVTEventCollectionViewItem.h
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EVTEvent, EVTImageFetcher;

@interface EVTEventCollectionViewItem : NSCollectionViewItem

@property (nonatomic, weak) EVTImageFetcher *imageFetcher;
@property (nonatomic, copy) EVTEvent *event;

@end
