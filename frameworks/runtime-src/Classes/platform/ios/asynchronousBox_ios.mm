#include "asynchronousBox_ios.h"
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "CCEAGLView-ios.h"
using namespace cocos2d;

asynchronousBox_ios::asynchronousBox_ios()
{
    
}

asynchronousBox_ios::~asynchronousBox_ios()
{
    
}

#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
UIWindow * s_windows = nullptr;
#endif
void asynchronousBox_ios::setWindows(void * windows)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    s_windows = (UIWindow*)windows;
#endif
}

static UIActivityIndicatorView * s_activityIndicatorView = NULL;
void asynchronousBox_ios::showAsynchronousBox()
{
    if(s_activityIndicatorView != NULL)
        return;
    if(s_windows == nullptr)
        return;
    s_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect winbounds = [s_windows bounds];
    [s_activityIndicatorView setCenter:CGPointMake(winbounds.size.width * 0.5f, winbounds.size.height * 0.5f)];
    s_activityIndicatorView.hidesWhenStopped = YES;
    [s_windows addSubview:s_activityIndicatorView];
    [s_activityIndicatorView startAnimating];
}

void asynchronousBox_ios::hideAsynchronousBox()
{
    if(s_activityIndicatorView!=NULL)
    {
        [s_activityIndicatorView stopAnimating];
        [s_activityIndicatorView removeFromSuperview];
        [s_activityIndicatorView release];
        s_activityIndicatorView = NULL;
    }
}

#endif