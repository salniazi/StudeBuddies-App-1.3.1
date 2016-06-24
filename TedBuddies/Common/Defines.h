#define defaults                            [NSUserDefaults standardUserDefaults]
#define SharedAppDelegate                   ((AppDelegate *)[[UIApplication sharedApplication] delegate])



//server url for staging and studebuddies 

//#define kBaseURL                            @"http://staging10.techaheadcorp.com/tedbuddy/api/Services/"
//#define kSocketURL                          @"ws://staging10.techaheadcorp.com/tedbuddy/api/"

#define kBaseURL                             @"http://studebuddies.com/api/Services/"
//#define kBaseURL                             @"http://krtyabackoffice.cloudapp.net:8096/api/Services"


#define kSocketURL                           @"ws://studebuddies.com/api/"
//#define kSocketURL                           @"ws://krtyabackoffice.cloudapp.net:8096/api/"



//#define kWebsiteURL                          @"http://krtyabackoffice.cloudapp.net:8096/"
#define kWebsiteURL                          @"http://studebuddies.com/"



#define kTwitterPermissionOfLogin    @"\"StudEBuddies\" doesn't have access to Twitter or there are no Twitter acounts configured. Please go and check Twitter in the iPhone Settings."
#define kFacebookPermissionOfLogin    @"\"StudEBuddies\" doesn't have access to Facebook or there are no Facebook acounts configured. Please go and check Facebook in the iPhone Settings."

#define kImageURl @""

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

//check device model
#define kIsIphone5    ([[UIScreen mainScreen] bounds].size.height > 480) ? YES : NO
#define kIsIphone6    ([[UIScreen mainScreen] bounds].size.height > 568) ? YES : NO
//#define kIsIphone6Plus    ([[UIScreen mainScreen] bounds].size.height > 667) ? YES : NO

#define kGrayGolor          [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]
#define kBlueColor          [UIColor colorWithRed:103.0/255.0  green:163.0/255.0 blue:201.0/255.0 alpha:0.8]
#define kLightGrayColor     [UIColor colorWithRed:146.0/255.0  green:146.0/255.0 blue:146.0/255.0 alpha:1.0]

#define kButtonBorderWidth                  1.0
#define kButtonCornerRadius                 5.0
typedef enum FriendStatus
{
    kStatusFriend = 1,
    KStatusFriendRequestPending,
    kStatusNotFriend,               //  Not a Friend
    kStatusMyRequestPending     
}friendStatus;


//FONT
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESSER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] < NSOrderedDescending)
#define SYSTEM_VERSION_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define FONT_LIGHT(font_size)                    [UIFont fontWithName:@"Helvetica-Light" size:font_size]
#define FONT_REGULAR(font_size)                  [UIFont fontWithName:@"Helvetica" size:font_size]
#define FONT_BOLD(font_size)                     [UIFont fontWithName:@"Helvetica-Bold" size:font_size]
//

#define kNavigationFontSize                 18
#define kButtonTextSize                     16

#define kIsLoggedIn                         @"inLoggedIn"
#define kIsFromCreateProfile                @"isFromCreateProfile"
#define kIsSocketOpen                       @"isSocketOpen"

#define kAPPNAME                            @"StudEBuddies"
#define kPleaseWait                         @"Please Wait..."


#define kResult                             @"Result"
#define kSuccess                            @"Success"
#define kMessage                            @"Message"
#define kRstKey                             @"rstKey"
#define kMessageSmall                       @"message"

//Signup
#define kSignupService                      @"Signup"
#define kEmailId                            @"emailId"
#define kPassword                           @"password"

//Login
#define kLoginService                       @"Login"
#define kLoginType                          @"loginType"  //1 for email, 2 for facebook, 3 for twitter
#define kFacebookId                         @"facebookId"
#define kInstaId                            @"InstagramId"
#define kTwitterId                          @"twitterId"
#define kUserId                             @"userId"
#define kIsCreated                          @"isCreated"
#define kDeviceToken                        @"deviceToken"
#define kDeviceType                         @"deviceType"

//tutorials key
#define kSignInTutorial                     @"signInTutorial"
#define kCreateProfileTutorial              @"createProfileTutorial"
#define kClassTitleTutorial                 @"classTitleTutorial"
#define kCoursePrefixTutorial               @"coursePrefixTutorial"
#define kMarketPlaceTutorial                @"marketPlaceTutorial"
#define kYapTutorial                        @"yapTutorial"
#define kPreferenceSettingsTutorial         @"preferenceSettingsTutorial"
#define kShowVideo                          @"showVideo"
#define kShowTutorial                       @"showTutial"
#define kShowUploadSchedule                 @"uploadSchedule"
#define kTimesAppOpened                     @"0"
//Preferences

#define kSetPrefrencesService               @"SetPrefrences"
#define kIsMajor                            @"isMajor"
#define kIsUniversity                       @"isUniversity"
#define kIsClassTitle                       @"isClassTitle"
#define kIsTimeSection                      @"isTimeSection"
#define kIsProfessor                        @"isProfessor"


//Preferences is common

#define kisMajorCommon                      @"isMajorCommon"
#define kisUniversityCommon                 @"isUniversityCommon"
#define kisClassTitleCommon                 @"isClassTitleCommon"
#define kisCourseNoCommon                   @"isCourseNoCommon"
#define kisSectionCommon                    @"isSectionCommon"


#define kGetPrefrences                      @"GetPrefrences"




//ForgotPassword
#define kForgotPassword                     @"ForgotPassword"

//GetProfessorList
#define kGetProfessorList                   @"GetCourseByUniversity"
#define kSearchText                         @"searchText"

//GetClassList
#define kGetClassesList                     @"GetClassesList"

//GetSectionList
#define kGetSectionList                     @"GetSectionList"

//Create Blog
#define kCreateBlog                         @"CreateBlog"

// View Profile
#define kBuddyId                            @"buddyId"

//Add Schedule keys

#define kClassId                            @"classId"
#define kClassTitle                         @"classTitle"
#define kProfessorId                        @"professorId"
#define kProfessorName                      @"professorName"
#define kMajorId                            @"majorId"
#define kMajorName                          @"majorName"
#define kSectionId                          @"sectionId"
#define kSectionName                        @"sectionName"
#define kUniversityId                       @"universityId"
#define kUniversityName                     @"universityName"
#define kClassDate                          @"classDate"
#define kClassTimeTo                        @"classTimeTo"
#define kClassTimeFrom                      @"classTimeFrom"
#define kShedClsId                          @"ShedClsId"
#define kCourseId                            @"courseId"
#define kCourseNo                            @"courseNo"

//GetMajorUniversityList

#define kGetMajorUniversityList             @"GetMajorUniversityList"
#define kLstMajor                           @"lstMajor"
#define kLstUniversity                      @"lstUniversity"

// Use in ckeck for Schedule status
#define kisCreated                          @"isCreated"
#define kiisclassuploaded                   @"isclassuploaded"

//CreateProfileApp

#define kCreateProfileApp                   @"CreateProfileApp"
#define kDob                                @"dob"
#define kName                               @"name"
#define kProfilePicture                     @"profilePicture"
#define kYearofCollage                      @"yearofCollage"
#define kObjSchecdule                       @"objSchecdule"
#define kAddionalProfilePicture             @"addtionalProfilePicture"


//FindBuddies
#define kFindBuddies                        @"FindBuddies"
#define kPage                               @"page"
#define kBuddyId                            @"buddyId"
#define kBuddyImage                         @"buddyImage"
#define kBuddyName                          @"buddyName"
#define kImage                              @"image"
#define kIsBuddy                            @"isBuddy"

//GetBuddyProfileDetail
#define kGetBuddyProfileDetail              @"GetBuddyProfileDetail"
#define kUniversity                         @"university"
#define kUniversityName                     @"universityName"


//send Invite
#define KSendInvitaion                      @"SendInvitaion"
#define kContactInvite                      @"ContactInvite"

//CreateBolg
#define kPostId                             @"PostId"
#define kPostHeading                        @"PostHeading"
#define kPostDescription                    @"PostDescription"
#define kIsBlog                             @"IsBlog"

//GetScheduledClassList
#define kGetScheduledClassList              @"GetScheduledClassList" 
#define kClassName                          @"className"

//BookInfoForISBN

#define kSendNoCourseNotificationForUniversity    @"SendNoCourseNotificationForUniversity"

// GetPostBlogList
#define kGetBookDetailFromISBN               @"getBookDetailFromISBN"
#define kISBN                                @"isbn"



#define kGetPostBlogList                    @"GetPostBlogList"

//GetAllPostBlogListing

#define kGetAllPostBlogListing              @"GetAllPostBlogListing"
#define kCreatedById                        @"createdById"


// Twitter Login

#define kLoading                            @"Loading"
//GetMyBuddiesList

#define kGetMyBuddiesList                   @"GetMyBuddiesList"

//GetPendingRequest

#define kGetPendingRequest                  @"GetPendingRequest"

//LeftClassGroupUser

#define kLeftClassGroupUser                  @"LeftClassGroupUser"

//SetMuteForClassUser

#define kSetMuteForClassUser                  @"SetMuteForClassUser"


// RespondInvitation

#define  kRespondInvitation                 @"RespondInvitation"
#define  kIsAccepted                        @"isAccepted"

// ScheduleClasses
#define kScheduleClasses                    @"ScheduleClasses"

// CreateMarketPlace
#define kCreateMarketPlace                  @"CreateMarketPlaceApp"
#define kMarketPlaceId                      @"mpId"
#define kMpName                             @"mpName"
#define kMpPrice                            @"mpPrice"
#define kMpContactEmail                     @"mpContactEmail"
#define kMpContactPhone                     @"mpContactPhone"
#define kMpDesc                             @"mpDesc"


// View MarketPlace
#define kGetAllMarketPlace                  @"GetAllMarketPlace"

// GetAllScheduledClassList
#define kGetAllScheduledClassList           @"GetAllScheduledClassList"

#define kCheckUniversityCredentials         @"CheckUniversityCredentials"

//GetChatHistory
#define kGetChatHistory                     @"GetChatHistory"
#define kGroupId                            @"groupId"
#define kUnreadCount                        @"unreadCount"

//CreateGroup
#define kCreateGroup                        @"CreateGroup"
#define kGroupName                          @"groupName"
#define kCreatedBy                          @"createdBy"
#define kGroupMember                        @"groupMember"
#define kUserName                           @"userName"
#define kProfileImage                       @"profileImage"


//GetRecentChatHistory
#define kGetRecentChatHistory               @"GetRecentChatHistory"
#define kCreatedDateChat                        @"createdDate"
#define kMessageType                        @"messageType"

//SaveChatImage
#define kSaveChatImage                      @"SaveChatImage"


//GetCollageYear
#define kGetCollageYear                     @"GetCollageYear"


//BlockBuddy
#define kBlockBuddy                         @"BlockBuddy"
#define kIsBlock                            @"isBlock"

//UpdateBadgeCounter

#define kUpdateBadgeCounter                 @"UpdateBadgeCounter"

//LogoutApp
#define kLogoutApp                          @"LogoutApp"

//GetContactSyncing
#define kGetContactSyncing                  @"GetContactSyncing"
#define kSyncingType                        @"syncingType"
#define kContactList                        @"contactList"


#define kBlogLike                           @"BlogLike"
#define kGetCommentsBlogWise                           @"GetCommentsBlogWise"
#define kAddComment                           @"AddComment"
#define kDeleteComment                           @"DeleteComment"
#define kSchedClassAction                           @"SchedClassAction"
#define kReportAbuse                           @"ReportAbuse"
#define kReportAProblem                           @"ReportAProblem"
#define kDeleteMarketPlace                           @"DeleteMarketPlace"
#define kDeletePost                           @"DeletePost"

inline static BOOL success(NSDictionary *response,NSError *error)
{
    BOOL isSuccess =[[response objectForKey:kSuccess] boolValue];
    if(!isSuccess)
    {
        if(!error)
        {
            
        }
    }
    return isSuccess;
}