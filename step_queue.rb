class Buffer
  EMPTY_SLOT = 0x666

  def initialize(capacity)
    @index = 0
    @capacity = capacity
    @buffer = Array.new(capacity, EMPTY_SLOT)
  end

	def set(index, object)
    position = index % @capacity
    while @buffer[position] != EMPTY_SLOT; end
    @buffer[position] = object
  end

  def get(index)
    position = index % @capacity
    while @buffer[position] == EMPTY_SLOT; end
    object = @buffer[position]
    @buffer[position] = EMPTY_SLOT
    object
  end
end

class Pusher
  def initialize(buffer, index, step)
    @buffer = buffer
    @index = index
    @step = step
  end

  def push(object)
    @buffer.set(@index, object)
    @index += @step
  end
end

class Poper
  def initialize(buffer, index, step)
    @index = index
    @buffer = buffer
    @step = step
  end

  def pop
    object = @buffer.get(@index)
    @index += @step
    object
  end
end

############# Benchmark shit #################

SET = 1_000_000
buffer = Buffer.new(SET)

threads = []

require 'thread'
q = Queue.new
SET.times { |i| q.push("#{i}") }

threads << Thread.new do
  pusher = Pusher.new(buffer, 0, 2)
  SET.times do |i|
    pusher.push("#{i}") if i % 2 == 0
  end
end

threads << Thread.new do
  pusher = Pusher.new(buffer, 1, 2)
  SET.times do |i|
    pusher.push("#{i}") if i % 2 == 1
  end
end

threads.map(&:join)
threads = []

a = Time.now

threads << Thread.new do
  poper = Poper.new(buffer, 0, 2)
  (SET / 2).times do |i|
    poper.pop
  end
end

threads << Thread.new do
  poper = Poper.new(buffer, 1, 2)
  (SET / 2).times do |i|
    poper.pop
  end
end

threads.map(&:join)
puts "StepQueue: %0.3f" % (Time.now - a)

threads = []
a = Time.now

threads << Thread.new do
  (SET / 2).times do |i|
    q.pop
  end
end

threads << Thread.new do
  (SET / 2).times do |i|
    q.pop
  end
end

threads.map(&:join)
puts "Queue: %0.3f" % (Time.now - a)
