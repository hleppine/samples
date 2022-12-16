#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/*
 * Usage: define the macros (see examples below):
 *  - GENERIC_BINARY_SEARCH__ITEM_T
 *  - GENERIC_BINARY_SEARCH__KEY_T
 *  - GENERIC_BINARY_SEARCH__TAG
 *  - GENERIC_BINARY_SEARCH__GET_KEY
 *  - GENERIC_BINARY_SEARCH__LESS_THAN
 * and include this file.
 *
 * The MISRA C:2012 advisory rules 20.5 and 20.10 are violated
 * as annotated below with cppcheck suppressions.
 */

#ifndef GENERIC_BINARY_SEARCH__ITEM_T
#define GENERIC_BINARY_SEARCH__ITEM_T int
#endif

#ifndef GENERIC_BINARY_SEARCH__KEY_T
#define GENERIC_BINARY_SEARCH__KEY_T int
#endif

#ifndef GENERIC_BINARY_SEARCH__TAG
#define GENERIC_BINARY_SEARCH__TAG Int
#endif

#ifndef GENERIC_BINARY_SEARCH__GET_KEY
#define GENERIC_BINARY_SEARCH__GET_KEY(ITEM) (ITEM)
#endif

#ifndef GENERIC_BINARY_SEARCH__LESS_THAN
#define GENERIC_BINARY_SEARCH__LESS_THAN(KEY_A, KEY_B) ((KEY_A) < (KEY_B))
#endif

// Define helper macros:

#define GENERIC_BINARY_SEARCH__JOIN(A, B) \
    A##B  // cppcheck-suppress misra-c2012-20.10
#define GENERIC_BINARY_SEARCH__IDENT(ROOT, NAME) \
    GENERIC_BINARY_SEARCH__JOIN(ROOT, NAME)

#define GENERIC_BINARY_SEARCH__ROOT \
    GENERIC_BINARY_SEARCH__IDENT(BinarySearch, GENERIC_BINARY_SEARCH__TAG)

#define GENERIC_BINARY_SEARCH__SEARCH \
    GENERIC_BINARY_SEARCH__IDENT(GENERIC_BINARY_SEARCH__ROOT, _search)

// Generic binary search implementation:

static inline bool GENERIC_BINARY_SEARCH__SEARCH(
    const GENERIC_BINARY_SEARCH__ITEM_T array[],
    size_t nbItems,
    GENERIC_BINARY_SEARCH__KEY_T key,
    size_t* index) {
    assert(array != NULL);
    assert(index != NULL);

    bool success = false;
    size_t low = 0;
    size_t nbItemsLeft = nbItems;
    size_t ret = 0;
    size_t mid;
    GENERIC_BINARY_SEARCH__KEY_T key_mid;
    while (nbItemsLeft > 0UL) {
        mid = low + (nbItemsLeft / 2UL);
        key_mid = GENERIC_BINARY_SEARCH__GET_KEY(array[mid]);
        if (GENERIC_BINARY_SEARCH__LESS_THAN(key, key_mid)) {
            ret = mid;
        } else if (GENERIC_BINARY_SEARCH__LESS_THAN(key_mid, key)) {
            low = mid + 1UL;
            nbItemsLeft--;
            ret = low;
        } else {
            success = true;
            ret = mid;
            break;
        }
        nbItemsLeft /= 2UL;
    }
    *index = ret;
    return success;
}

// Undefine all macros defined in this file:

#undef GENERIC_BINARY_SEARCH__ITEM_T     // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__KEY_T      // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__TAG        // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__GET_KEY    // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__LESS_THAN  // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__JOIN       // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__IDENT      // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__ROOT       // cppcheck-suppress misra-c2012-20.5
#undef GENERIC_BINARY_SEARCH__SEARCH     // cppcheck-suppress misra-c2012-20.5
