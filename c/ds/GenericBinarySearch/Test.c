#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    uint32_t key;
    double value;
} foo_t;

#define GENERIC_BINARY_SEARCH__ITEM_T foo_t
#define GENERIC_BINARY_SEARCH__KEY_T uint32_t
#define GENERIC_BINARY_SEARCH__TAG Foo
#define GENERIC_BINARY_SEARCH__GET_KEY(ITEM) (ITEM.key)
#define GENERIC_BINARY_SEARCH__LESS_THAN(KEY_A, KEY_B) ((KEY_A) < (KEY_B))
#include "GenericBinarySearch.h"

static inline bool linearSearch(const foo_t array[],
                                size_t nbItems,
                                uint32_t key,
                                size_t* index) {
    if (key < array[0].key) {
        *index = 0;
        return false;
    } else if (key > array[nbItems - 1].key) {
        *index = nbItems;
        return false;
    } else {
        for (size_t i = 0; i < nbItems; i++) {
            if (array[i].key == key) {
                *index = i;
                return true;
            } else if (key > array[i].key && key < array[i + 1].key) {
                *index = i + 1;
                return false;
            }
        }
    }
    *index = 0;
    return false;
}

int main() {
    foo_t arr[1000];

    // Fill table
    uint32_t iPrev = 10;
    for (uint32_t i = 0; i < 1000; i++) {
        arr[i] = (foo_t){
            .key = i + iPrev,
            .value = (double)((i + iPrev) * (i + iPrev)),
        };
        iPrev += i;
    }

    /*
     * Loop over a key range covering keys before the array,
     * after the array, and in between the keys within the array.
     *
     * Check that the binary search result is always equivalent
     * with the linear search result.
     */
    const uint32_t first = 0;
    const uint32_t last = arr[999].key + 10;

    for (uint32_t i = first; i < last; i++) {
        size_t binIndex;
        size_t linIndex;
        // printf("%d %d\n", i, arr[i].key);
        bool binSuccess = BinarySearchFoo_search(arr, 1000, i, &binIndex);
        bool linSuccess = linearSearch(arr, 1000, i, &linIndex);
        // printf("%d %d %ld %ld\n", binSuccess, linSuccess, binIndex,
        // linIndex);
        assert(binSuccess == linSuccess);
        assert(binIndex == linIndex);
    }

    printf("Test done\n");

    return 0;
}
