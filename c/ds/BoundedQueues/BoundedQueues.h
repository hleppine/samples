#ifndef BoundedQueues_H
#define BoundedQueues_H

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/**
 * A bounded queue.
 *  - The queue and item sizes are configured at queue initialization.
 *  - A buffer is also provided to be used by the queue.
 *  - Items are memcopied in and out of the queue.
 */
typedef struct {
    size_t maxNbItems;   /**< \private */
    size_t itemNbOctets; /**< \private */
    size_t nbItems;      /**< \private */
    uint8_t* startPtr;   /**< \private */
    uint8_t* endPtr;     /**< \private */
    uint8_t* frontPtr;   /**< \private */
    uint8_t* backPtr;    /**< \private */
} BoundedQueues_Queue_T;

/**
 * Initializes a bounded queue.
 * @param queue The queue to initialize.
 * @param buffer The buffer to use for the queue.
 * @param bufferNbOctets Size of the buffer in octets.
 * @param maxNbItems Maximum number of items in the queue.
 * @param itemNbOctets Size of one item in octets.
 */
static inline void BoundedQueues_initialize(BoundedQueues_Queue_T* queue,
                                            uint8_t* buffer,
                                            size_t bufferNbOctets,
                                            size_t maxNbItems,
                                            size_t itemNbOctets) {
    assert(queue != NULL);
    assert(buffer != NULL);
    assert(bufferNbOctets == (maxNbItems * itemNbOctets));
    *queue = (BoundedQueues_Queue_T){
        .maxNbItems = maxNbItems,
        .itemNbOctets = itemNbOctets,
        .nbItems = 0,
        .startPtr = buffer,
        .endPtr = &buffer[itemNbOctets * (maxNbItems - 1UL)],
        .frontPtr = buffer,
        .backPtr = &buffer[itemNbOctets * (maxNbItems - 1UL)],
    };
}

/**
 * Returns the current number of items in the queue.
 * @param queue The queue to access.
 */
static inline uint32_t BoundedQueues_nbItems(
    const BoundedQueues_Queue_T* queue) {
    assert(queue != NULL);
    return queue->nbItems;
}

/**
 * Returns true if the queue is full, false otherwise.
 * @param queue The queue to access.
 */
static inline bool BoundedQueues_isFull(const BoundedQueues_Queue_T* queue) {
    assert(queue != NULL);
    return queue->nbItems == queue->maxNbItems;
}

/**
 * Returns true if the queue is empty, false otherwise.
 * @param queue The queue to access.
 */
static inline bool BoundedQueues_isEmpty(const BoundedQueues_Queue_T* queue) {
    assert(queue != NULL);
    return queue->nbItems == 0UL;
}

/**
 * Put an item in the queue.
 * Returns true if the operation succeeded, and false otherwise.
 * @param queue The queue to access.
 * @param item The item to put.
 */
static inline bool BoundedQueues_put(BoundedQueues_Queue_T* queue,
                                     const void* item) {
    assert(queue != NULL);
    assert(item != NULL);
    bool success = !BoundedQueues_isFull(queue);
    if (success) {
        queue->nbItems++;
        // Move back pointer one item to the right, or wrap around.
        queue->backPtr = (queue->backPtr == queue->endPtr)
                             ? queue->startPtr
                             : &queue->backPtr[queue->itemNbOctets];
        (void)memcpy(queue->backPtr, item, queue->itemNbOctets);
    }
    return success;
}

/**
 * Put an item to the front of the queue.
 * Returns true if the operation succeeded, and false otherwise.
 * @param queue The queue to access.
 * @param item The item to put.
 */
static inline bool BoundedQueues_putToFront(BoundedQueues_Queue_T* queue,
                                            const void* item) {
    assert(queue != NULL);
    assert(item != NULL);
    bool success = !BoundedQueues_isFull(queue);
    if (success) {
        queue->nbItems++;
        // Move front pointer one item to the left, or wrap around.
        queue->frontPtr = (queue->frontPtr == queue->startPtr)
                              ? queue->endPtr
                              : &queue->frontPtr[-queue->itemNbOctets];
        (void)memcpy(queue->frontPtr, item, queue->itemNbOctets);
    }
    return success;
}

/**
 * Get an item from the queue.
 * Returns true if the operation succeeded, and false otherwise.
 * @param queue The queue to access.
 * @param item The obtained item, valid only if true was returned.
 */
static inline bool BoundedQueues_get(BoundedQueues_Queue_T* queue, void* item) {
    assert(queue != NULL);
    assert(item != NULL);
    bool success = !BoundedQueues_isEmpty(queue);
    if (success) {
        queue->nbItems--;
        (void)memcpy(item, queue->frontPtr, queue->itemNbOctets);
        // Move front pointer one item to the right, or wrap around.
        queue->frontPtr = (queue->frontPtr == queue->endPtr)
                              ? queue->startPtr
                              : &queue->frontPtr[queue->itemNbOctets];
    }
    return success;
}

/**
 * Get an item from the back of the queue.
 * Returns true if the operation succeeded, and false otherwise.
 * @param queue The queue to access.
 * @param item The obtained item, valid only if true was returned.
 */
static inline bool BoundedQueues_getFromBack(BoundedQueues_Queue_T* queue,
                                             void* item) {
    assert(queue != NULL);
    assert(item != NULL);
    bool success = !BoundedQueues_isEmpty(queue);
    if (success) {
        queue->nbItems--;
        (void)memcpy(item, queue->backPtr, queue->itemNbOctets);
        // Move back pointer one item to the left, or wrap around.
        queue->backPtr = (queue->backPtr == queue->startPtr)
                             ? queue->endPtr
                             : &queue->backPtr[-queue->itemNbOctets];
    }
    return success;
}

#endif /* BoundedQueues_H */
