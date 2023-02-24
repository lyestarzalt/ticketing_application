# Author: Lyes Tarzalt
class IQueuable:
    def enqueue(self, value: str) -> list:
        pass
    # method naming in python is snake_case but im following the assessment
    # instructions.

    def dequeue(self) -> str:
        pass

    def getQueue(self) -> list:
        pass

    def size(self) -> int:
        pass


class FIFOQueue(IQueuable):
    def __init__(self):
        self.queue = []

    def enqueue(self, value):
        self.queue.append(value)
        return self.queue

    def dequeue(self):
        if not self.queue:
            return "Queue is empty"
        return self.queue.pop(0)

    def getQueue(self):
        return self.queue

    def size(self):
        return len(self.queue)


class LIFOQueue(IQueuable):
    def __init__(self):
        self.queue = []

    def enqueue(self, value):
        self.queue.append(value)
        return self.queue

    def dequeue(self):
        if not self.queue:
            return "Queue is empty"
        return self.queue.pop()

    def getQueue(self):
        return self.queue

    def size(self):
        return len(self.queue)

# Example:


if __name__ == "__main__":
    # Example of FIFOQueue
    fifo = FIFOQueue()
    fifo.enqueue("Nasi Lemak")
    fifo.enqueue("Laksa")
    fifo.enqueue("Roti Canai")
    print(fifo.getQueue())
    fifo.dequeue()
    print(fifo.getQueue())

    lifo = LIFOQueue()
    lifo.enqueue("Nasi Lemak")
    lifo.enqueue("Laksa")
    lifo.enqueue("Roti Canai")
    print(lifo.getQueue())
    lifo.dequeue()
    print(lifo.getQueue())
