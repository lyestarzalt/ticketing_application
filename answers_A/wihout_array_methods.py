# Author: Lyes Tarzalt
class FIFOQueue:
    def __init__(self):
        self.queue = []
        self.front = 0
        self.rear = 0

    def enqueue(self, value):
        # I had to google some part of this, since I didnt come
        # across this before we are spoiled by modern languages :)
        new_queue = [None] * (self.rear - self.front + 1)
        for i in range(self.front, self.rear):
            new_queue[i - self.front] = self.queue[i]
        new_queue[self.rear - self.front] = value
        self.rear += 1
        self.queue = new_queue
        return self.queue

    def dequeue(self):
        if self.front == self.rear:
            return "Queue is empty"
        front_value = self.queue[self.front]
        self.front += 1
        return front_value

    def getQueue(self):
        return self.queue[self.front:]

    def size(self):
        return self.rear - self.front


if __name__ == "__main__":
    # Example of FIFOQueue wihtout list methods.
    fifo = FIFOQueue()
    fifo.enqueue("Nasi Lemak")
    fifo.enqueue("Laksa")
    fifo.enqueue("Roti Canai")
    print(fifo.getQueue())
    fifo.dequeue()
    print(fifo.getQueue())
