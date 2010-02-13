// Copyright OpenResearch Software Development OG 2010. All rights reserved.

#ifdef DEBUG
    #define ZTLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #define ZTLogRect(r)    NSLog(@"%s(%d): NSRect <x:%f y:%f w:%f h:%f>", __PRETTY_FUNCTION__, __LINE__, r.origin.x, r.origin.y, r.size.width, r.size.height)
#else
    #define ZTLog(r)         ((void)0)
    #define ZTLogRect(...)   ((void)0)
#endif