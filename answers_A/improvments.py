# Author: Lyes Tarzalt

from enum import Enum


class QueueType(Enum):
    FIFO = 1
    LIFO = 2


class Queue:
    def __init__(self, qtype):
        self.queue = []
        self.qtype = qtype

    def enqueue(self, value):
        if self.qtype == QueueType.FIFO:
            self.queue.append(value)
        elif self.qtype == QueueType.LIFO:
            self.queue.insert(0, value)
        return self.queue

    def dequeue(self):
        if not self.queue:
            return "Queue is empty"
        if self.qtype == QueueType.FIFO:
            return self.queue.pop(0)
        elif self.qtype == QueueType.LIFO:
            return self.queue.pop()

    def getQueue(self):
        return self.queue

    def size(self):
        return len(self.queue)


if __name__ == "__main__":
    # create a FIFO queue and enqueue elements
    fifo_queue = Queue(QueueType.FIFO)
    fifo_queue.enqueue("Nasi Lemak")
    fifo_queue.enqueue("Laksa")
    fifo_queue.enqueue("Roti Canai")
    print("FIFO Queue: ", fifo_queue.getQueue())

    print("Dequeue: ", fifo_queue.dequeue())
    print("Dequeue: ", fifo_queue.dequeue())
    print("FIFO Queue: ", fifo_queue.getQueue())

    lifo_queue = Queue(QueueType.LIFO)
    lifo_queue.enqueue("Nasi Lemak")
    lifo_queue.enqueue("Laksa")
    lifo_queue.enqueue("Roti Canai")
    print("LIFO Queue: ", lifo_queue.getQueue())

    print("Dequeue : ", lifo_queue.dequeue())
    print("Dequeue: ", lifo_queue.dequeue())
