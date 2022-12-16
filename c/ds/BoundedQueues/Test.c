#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "BoundedQueues.h"

void test_queue(uint8_t* buffer,
                uint32_t bufferNbOctets,
                uint32_t maxNbItems,
                uint32_t itemNbOctets) {
    BoundedQueues_Queue_T queue;
    bool success;
    uint8_t item_buf[itemNbOctets];
    uint8_t item_buf2[itemNbOctets];

    printf("Testing queue with maxNbItems=%d, itemNbOctets=%d.\n", maxNbItems,
           itemNbOctets);

    // Test initialization
    BoundedQueues_initialize(&queue, buffer, bufferNbOctets, maxNbItems,
                             itemNbOctets);

    // Get from empty
    success = BoundedQueues_get(&queue, item_buf);
    assert(!success);

    // Fill queue.
    for (int i = 0; i < (int)maxNbItems; i++) {
        // Put successfully.
        memset(item_buf, i, itemNbOctets);
        success = BoundedQueues_put(&queue, item_buf);
        assert(success);
    }

    // Put with failure.
    success = BoundedQueues_put(&queue, item_buf);
    assert(!success);

    for (int i = 0; i < (int)maxNbItems; i++) {
        // Get and compare.
        memset(item_buf2, i, itemNbOctets);
        success = BoundedQueues_get(&queue, item_buf);
        assert(!memcmp(item_buf, item_buf2, itemNbOctets));
    }

    for (int i = 0; i < (int)maxNbItems; i++) {
        // Put successfully.
        memset(item_buf, i, itemNbOctets);
        success = BoundedQueues_put(&queue, item_buf);
        assert(success);

        // Get and compare.
        success = BoundedQueues_get(&queue, item_buf2);
        assert(!memcmp(item_buf, item_buf2, itemNbOctets));
    }

    (void)success;
    printf("Test passed\n");
}

int main() {
    uint8_t buffer[10000];

    test_queue(buffer, 20, 5, 4);

    test_queue(buffer, 1000, 100, 10);

    test_queue(buffer, 10000, 2000, 5);

    return 0;
}
