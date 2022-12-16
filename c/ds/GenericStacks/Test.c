#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define GENERIC_STACKS__ITEM_T uint32_t
#define GENERIC_STACKS__TAG U32
#include "GenericStacks.h"

static void testStack(uint32_t buffer[], uint32_t maxNbItems) {
    StacksU32_Stack_T stack;
    bool success;
    uint32_t item;

    (void)printf("Testing stack with maxNbItems=%d.\n", maxNbItems);

    // Test initialization.
    StacksU32_initialize(&stack, buffer, maxNbItems);

    // Stack should be initially empty.
    assert(StacksU32_nbItems(&stack) == 0UL);

    // Pop from empty.
    success = StacksU32_pop(&stack, &item);
    assert(!success);

    // Peek from empty.
    success = StacksU32_peek(&stack, &item);
    assert(!success);

    // Fill stack.
    for (uint32_t i = (uint32_t)0UL; i < maxNbItems; i++) {
        success = StacksU32_push(&stack, &i);
        assert(success);
        assert(StacksU32_nbItems(&stack) == (i + 1UL));
        success = StacksU32_peek(&stack, &item);
        assert(success);
        assert(item == i);
    }

    // Push to full.
    item = 0;
    success = StacksU32_push(&stack, &item);
    assert(!success);
    assert(StacksU32_nbItems(&stack) == maxNbItems);

    // Empty the stack.
    for (uint32_t i = maxNbItems; i > 0UL; i--) {
        success = StacksU32_peek(&stack, &item);
        assert(success);
        assert(item == (i - 1UL));
        success = StacksU32_pop(&stack, &item);
        assert(item == (i - 1UL));
        assert(StacksU32_nbItems(&stack) == (i - 1UL));
    }

    (void)success;
    (void)printf("Test passed\n");
}

int main(void) {
    uint32_t buffer[10000];

    testStack(buffer, 20);

    testStack(buffer, 1000);

    testStack(buffer, 10000);

    return 0;
}
