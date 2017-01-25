#import <Security/Security.h>
#import <Foundation/Foundation.h>
#import <iso646.h>
#import <libgen.h>

/*
    define the various types of `SecKeychainStatus` values that can be returned.

    this is important to know when the keychain specified is actually unlocked or not.
 */
enum keychain_status {
    status_locked = 0,
    status_unlocked = kSecUnlockStateStatus,
    status_read = kSecReadPermStatus,
    status_unlocked_read = (kSecUnlockStateStatus + kSecReadPermStatus),
    status_write = kSecWritePermStatus,
    status_unlocked_write = (kSecUnlockStateStatus + kSecWritePermStatus),
    status_read_write = (kSecReadPermStatus + kSecWritePermStatus),
    status_unlocked_read_write = (kSecUnlockStateStatus + kSecReadPermStatus + kSecWritePermStatus),
};

/**
 * Takes a c-string path to the `.keychain` file, and returns "0" or "1" based on if the keychain is unlocked.
 *
 * note: the path must be an absolute path 
 */
int isKeychainUnlocked(char *keychain_path) {
    int is_keychain_unlocked = 0;
    
    SecKeychainRef storage_keychain = NULL;
    OSStatus open_result = SecKeychainOpen(keychain_path, &storage_keychain);
    if (open_result != errSecSuccess) {
        goto exit;
    }
            
    SecKeychainStatus status = 0;
    OSStatus status_result = SecKeychainGetStatus(storage_keychain, &status);
    if (status_result != errSecSuccess) {
        goto exit;
    }
            
    switch (status) {
        case status_unlocked:
        case status_unlocked_read:
        case status_unlocked_write:
        case status_unlocked_read_write: {
            is_keychain_unlocked = 1;
            break;
        }
        default: {
            break;
        }
    }

exit:
    return is_keychain_unlocked;
}


/**
 * Takes a c-string path to the `.keychain` file, and returns "0" or "1" based on if the keychain was able to be unlocked.
 *
 * note: the path must be an absolute path 
 */
int unlockKeychain(char *keychain_path) {
    int is_now_unlocked = 0;

    SecKeychainRef login_keychain = NULL;
    OSStatus default_result = SecKeychainCopyDefault(&login_keychain);
    if (default_result != errSecSuccess) {
        goto exit;
    }

    SecKeychainRef storage_keychain = NULL;
    OSStatus open_result = SecKeychainOpen(keychain_path, &storage_keychain);
    if (open_result != errSecSuccess) {
        goto exit;
    }
    
    if (isKeychainUnlocked(keychain_path)) {
        char *name = basename(keychain_path);
        char *account_name = "login";
        UInt32 password_length = 0;
        void *password_data = NULL;
        OSStatus find_password_result = SecKeychainFindGenericPassword(login_keychain, strlen(name), name, strlen(account_name), account_name, &password_length, &password_data, NULL);
        if (find_password_result != errSecSuccess) {
            goto exit;
        }
        
        OSStatus unlock_result = SecKeychainUnlock(storage_keychain, password_length, password_data, true);
        SecKeychainItemFreeContent(NULL, password_data);
        if (unlock_result != errSecSuccess) {
            goto exit;
        }

        is_now_unlocked = 1;
    }

exit:
    return is_now_unlocked;
}

/**
 * Takes a c-string name of an item in the keychain to extract and a c-string path to the `.keychain` file, it
 * returns a c-string of the password field of the item with name specified by the `token_name` parameter. this
 * function will return an empty string if no items were found, or on any failure to access the item.
 *
 * note: the path must be an absolute path 
 */
char * getTokenFromKeychain(char *token_name, char *keychain_path) {
    char *token = "";

    int usable_keychain = unlockKeychain(keychain_path);
    if (not usable_keychain) {
        goto exit;
    }

    SecKeychainRef storage_keychain = NULL;
    OSStatus open_result = SecKeychainOpen(keychain_path, &storage_keychain);
    if (open_result != errSecSuccess) {
        goto exit;
    }

    UInt32 token_length = 0;
    void *token_data = NULL;
    OSStatus token_result = SecKeychainFindInternetPassword(storage_keychain, 0, "", 0, NULL, strlen(token_name), token_name, 0, "", 0, kSecProtocolTypeAny, kSecAuthenticationTypeDefault, &token_length, &token_data, NULL);
    if (token_result != errSecSuccess) {
        SecKeychainItemFreeContent(NULL, token_data);
        goto exit;
    }

    size_t alloc_length = token_length + 1;
    token = calloc(alloc_length, sizeof(char));
    memcpy(token, token_data, sizeof(char[token_length]));

    SecKeychainItemFreeContent(NULL, token_data);

exit:
    return token;
}
