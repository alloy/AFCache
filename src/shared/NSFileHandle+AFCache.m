//
//  NSFileHandle+AFCache.m
//  AFCache
//
//  Created by Lars Blumberg on 15.08.14.
//  Copyright (c) 2014 Artifacts - Fine Software Development. All rights reserved.
//

#include <sys/xattr.h>
#import <AFCache/AFCache.h>
#import "NSFileHandle+AFCache.h"
#import "AFCache_Logging.h"

//const char* kAFCacheContentLengthFileAttribute = "de.artifacts.contentLength";
//const char* kAFCacheDownloadingFileAttribute = "de.artifacts.downloading";

@implementation NSFileHandle (AFCache)

#ifdef AFCACHE_LOGGING_ENABLED
- (NSString *)af_filename;
{
    char filename[PATH_MAX];
    if (fcntl(self.fileDescriptor, F_GETPATH, filename) != -1) {
        return [NSString stringWithUTF8String:filename];
    }
    return nil;
}
#endif

- (void)flagAsDownloadStartedWithContentLength: (uint64_t)contentLength {
    int fd = [self fileDescriptor];
    if (fd <= 0) {
        return;
    }
    if (0 != fsetxattr(fd, kAFCacheContentLengthFileAttribute, &contentLength, sizeof(uint64_t), 0, 0)) {
        AFLog(@"Could not set contentLength attribute on %@", self.af_filename);
    }
    unsigned int downloading = 1;
    if (0 != fsetxattr(fd, kAFCacheDownloadingFileAttribute, &downloading, sizeof(downloading), 0, 0)) {
        AFLog(@"Could not set downloading attribute on %@", self.af_filename);
    }
}

- (void)flagAsDownloadFinishedWithContentLength: (uint64_t)contentLength {
    int fd = [self fileDescriptor];
    if (fd <= 0) {
        return;
    }
    if (0 != fsetxattr(fd, kAFCacheContentLengthFileAttribute, &contentLength, sizeof(uint64_t), 0, 0)) {
        AFLog(@"Could not set contentLength attribute on %@, errno = %ld", self.af_filename, (long)errno );
    }
    if (0 != fremovexattr(fd, kAFCacheDownloadingFileAttribute, 0)) {
        AFLog(@"Could not remove downloading attribute on %@, errno = %ld", self.af_filename, (long)errno );
    }
}

@end
