//
//  GifDisplayViewController.m
//  GiphyClient
//
//  Created by Jared Halpern on 9/11/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import "GifDisplayViewController.h"
#import "SearchGifViewController.h"

@interface GifDisplayViewController ()
@property (nonatomic, strong) UISearchBar                *searchBar;
@property (nonatomic, strong) UIButton                   *searchCloseButton;
@property (nonatomic, strong) SearchGifViewController    *searchVC;
@property (nonatomic, strong) NSLayoutConstraint         *searchVCTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint         *searchVCHeightConstraint;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@end

@implementation GifDisplayViewController

#pragma mark - View Lifecycle

- (instancetype)init
{
  if (self = [super init]) {
      
      

  }
  return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    // free up UIImages in earlier part of collection
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:103/255.0f green:163/255.0f blue:201/255.0f alpha:1];
    
    [self setupSearchBar];
    _collectionViewLayout= [[UICollectionViewFlowLayout alloc] init];
    //  _collectionViewLayout.minimumLineSpacing = 5;
    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = YES;
    _collectionView.contentInset = UIEdgeInsetsZero;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_collectionView registerClass:[GifCollectionViewCell class] forCellWithReuseIdentifier:cellReuseId];
    [self.view addSubview:_collectionView];
    
    [self setupConstraints];
    
    
    
    
    
    _dataArray = [[NSMutableArray alloc] init];
    
    _offset = 0;
    self.view.clipsToBounds = NO;
    
    // Setup Progress HUD Appearance
    [SVProgressHUD setBackgroundColor:kColorFeedBackground];
    [SVProgressHUD setForegroundColor:kColorDarkBlue];
    
    
    [SVProgressHUD show];
    self.loadingGifs = YES;
    
    
    [[APIManager sharedManager] getTrendingGifsWithOffset:self.offset andCompletion:^(NSArray *data, NSInteger offset) {
        self.dataArray = [[self.dataArray arrayByAddingObjectsFromArray:data] mutableCopy];
        self.offset = offset;
        [self.collectionView reloadData];
        self.loadingGifs = NO;
        [SVProgressHUD dismiss];
    }];
   
    
   
  }
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}
- (void)setupConstraints
{
  self.constraints = [@[] mutableCopy];
  
  // collectionView
  [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(22)-[_searchBar][_collectionView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_searchBar,_collectionView)]];

  [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchBar][_searchCloseButton(60)]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_searchBar, _searchCloseButton)]];
  
  [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_collectionView)]];
  // searchBar
  [self.constraints addObject:[NSLayoutConstraint constraintWithItem:_searchCloseButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_searchBar
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0]];
  
  [self.constraints addObject:[NSLayoutConstraint constraintWithItem:_searchCloseButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_searchBar
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0]];
  [self.view addConstraints:self.constraints];
}

- (void)setupSearchBar
{
  _searchBar = [[UISearchBar alloc] init];
 // _searchBar.barTintColor = kColorLightBlue;
  _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
  _searchBar.delegate = self;
  _searchBar.searchBarStyle = UISearchBarStyleDefault;
  _searchBar.placeholder = NSLocalizedString(@"Search all GIFs", nil);
  _searchBar.clearsContextBeforeDrawing = YES;
  _searchBar.showsCancelButton = NO;
  _searchBar.showsBookmarkButton = NO;
  _searchBar.translucent = NO;
  
  [self.view addSubview:_searchBar];
  
    _searchCloseButton = [[UIButton alloc] init];
    _searchCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchCloseButton setTitle:@"Cancel" forState:UIControlStateNormal];
    //[_searchCloseButton setTitleColor:kColorDarkBlue forState:UIControlStateNormal];
    [_searchCloseButton setTitleColor:_searchCloseButton.tintColor forState:UIControlStateNormal];
    //_searchCloseButton.titleLabel.font = kFontRegular;
    _searchCloseButton.backgroundColor = [UIColor colorWithRed:198.0f/255.0f green:197.0f/255.0f blue:203.0f/255.0f alpha:1.0];//kColorLightBlue;
    //_searchCloseButton.enabled = NO;
    _searchCloseButton.userInteractionEnabled = YES;
    _searchCloseButton.layer.borderWidth = 0.5;
    _searchCloseButton.layer.borderColor = [UIColor colorWithRed:188.0f/255.0f green:187.0f/255.0f blue:190.0f/255.0f alpha:1.0].CGColor;//[kColorDarkestBlue CGColor];
    [_searchCloseButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchCloseButton];
}

#pragma mark - ContainerView

- (void)dismissSearchGifViewController
{
 //self.searchCloseButton.enabled = NO;
  [self.searchCloseButton setTitle:@"Cancel" forState:UIControlStateDisabled];
  self.searchBar.text = nil;
  [self.searchBar resignFirstResponder];
  [self.view layoutIfNeeded];
  
  if (!self.searchVC) {
      [self dismissViewControllerAnimated:YES completion:nil];
    return;
  }
  
  [UIView animateWithDuration:kTimeSearchVCSlide animations:^{
    [self.view removeConstraint:self.searchVCTopConstraint];
    [self.view removeConstraint:self.searchVCHeightConstraint];
    
    self.searchVCTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    
    [self.view addConstraint:self.searchVCTopConstraint];
    [self.view layoutIfNeeded];
    
  } completion:^(BOOL finished) {
    [self.searchVC willMoveToParentViewController:nil];
    [self.searchVC.view removeFromSuperview];
    [self.searchVC removeFromParentViewController];
    [self.view layoutIfNeeded];
    self.searchVC = nil;
  }];
}

- (void)showSearchGifViewController
{
  self.searchCloseButton.enabled = YES;
  [self.searchCloseButton setTitle:@"Close" forState:UIControlStateNormal];
  
  if (!self.searchVC) {
    self.searchVC = [[SearchGifViewController alloc] init];
    self.searchVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.searchVC];
    [self.view addSubview:self.searchVC.view];
    
    // Set up constraints
    NSMutableArray *constraints = [@[] mutableCopy];
    self.searchVCHeightConstraint = [NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:-kNavBarHeight - kKeylineHeight];  // preserve that little keyline under the search bar.
    
    self.searchVCTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [self.view addConstraint:self.searchVCHeightConstraint];
    [self.view addConstraint:self.searchVCTopConstraint];
    [self.view addConstraints:constraints];
    
    [self.view layoutIfNeeded];
    
    // Animate and slide in Search VC
    
    [UIView animateWithDuration:kTimeSearchVCSlide animations:^{
      [self.view removeConstraint:self.searchVCTopConstraint];
      
      self.searchVCTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:kNavBarHeight + kKeylineHeight];
      
      [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchVC.view
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0.0]];
      
      [self.view addConstraint:self.searchVCTopConstraint];
      [self.view layoutIfNeeded];
      
    } completion:^(BOOL finished) {
      [self.searchVC didMoveToParentViewController:self];
    }];
  }
  
  self.searchVC.loadingGifs = YES;
  
  __weak GifDisplayViewController *welf = self;
  
  // do the initial search, so the data is ready faster after the search screen presents itself
  // rather than waiting for it to load
  [[APIManager sharedManager] searchTerms:self.searchBar.text withOffset:(self.offset) andCompletion:^(NSArray *data, NSString *searchTerms, NSInteger offset) {
    [welf.searchVC setSearchTerms:searchTerms];    
    welf.searchVC.offset = offset;
    welf.searchVC.dataArray = [data mutableCopy]; // don't want to append here since we're doing a new search
    [self.searchVC.collectionView reloadData];
    [SVProgressHUD dismiss];
    self.searchVC.loadingGifs = NO;
    [self.searchBar resignFirstResponder];    
  }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  self.searchCloseButton.enabled = YES;
  [self.searchCloseButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [self dismissSearchGifViewController];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [SVProgressHUD show];
  [self showSearchGifViewController];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1.0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  GifCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseId forIndexPath:indexPath];
  //cell.contentView.layer.cornerRadius = 15;
  cell.contentView.layer.borderWidth = 1.0;
  cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
  cell.contentView.layer.masksToBounds = YES;
  cell.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
  cell.layer.shadowOffset = CGSizeMake(0, 2.0f);
  cell.layer.shadowRadius = 0.0f;
  cell.layer.shadowOpacity = 1.0f;
  cell.layer.masksToBounds = NO;
  cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;

  NSURL *imageURL = [self.dataArray objectAtIndex:indexPath.row][@"images"][@"fixed_width_downsampled"][@"url"];
  [cell setImageURL:imageURL];
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataArray objectAtIndex:indexPath.row]];
    SharedAppDelegate.responceGIF=[[NSMutableArray alloc] init];
    [SharedAppDelegate.responceGIF addObject:dataDict];
  
    [self dismissViewControllerAnimated:YES completion:nil];
//  SingleGifViewController *singleGifVC = [[SingleGifViewController alloc] initWithDict:dataDict];
//  [self.navigationController pushViewController:singleGifVC animated:YES];
//  self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//  NSDictionary *dict =  [self.dataArray objectAtIndex:indexPath.row][@"images"][@"fixed_width_downsampled"];
//  NSInteger width =  [[dict objectForKey:@"width"] integerValue];
//  NSInteger height = [[dict objectForKey:@"height"] integerValue];
//
//  return CGSizeMake(width * 1.4, height * 1.4); // scale up
    
    CGSize mElementSize = CGSizeMake(_collectionView.frame.size.width/5.65,_collectionView.frame.size.height/6);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //     return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(5,5,5,5);  // top, left, bottom, right
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
 //self.searchCloseButton.enabled = NO;
  self.searchBar.text = @"";
}

@end
