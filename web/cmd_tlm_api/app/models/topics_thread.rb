# encoding: ascii-8bit

# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder

require 'cosmos'
Cosmos.require_file 'cosmos/utilities/store'

class TopicsThread
  def initialize(topics, channel, history_count = 0, max_batch_size = 100)
    @topics = topics
    @offsets = Array.new(topics.length, "0-0")
    @channel = channel
    @history_count = history_count.to_i
    @max_batch_size = max_batch_size
    @cancel_thread = false
    @thread = nil
    @offset_index_by_topic = {}
    @topics.each_with_index do |topic, index|
      @offset_index_by_topic[topic] = index
    end
  end

  def start
    @thread = Thread.new do
      begin
        thread_setup()
        while true
          break if @cancel_thread
          thread_body()
          break if @cancel_thread
        end
      rescue => err
        Cosmos::Logger.error "#{self.class.name} unexpectedly died\n#{err.formatted}"
      ensure
        thread_teardown()
      end
    end
  end

  def stop
    @cancel_thread = true
  end

  def transmit_results(results, force: false)
    if results.length > 0 or force
      @channel.send(:transmit, JSON.generate(results.as_json))
    end
  end

  def thread_setup
    @topics.each do |topic|
      results = Cosmos::Store.instance.xrevrange(topic, '+', '-', count: @history_count)
      batch = []
      results.reverse.each do |msg_id, msg_hash|
        @offsets[@offset_index_by_topic[topic]] = msg_id
        batch << msg_hash
        if batch.length > @max_batch_size
          transmit_results(batch)
          batch.clear
        end
      end
      transmit_results(batch)
    end
  end

  def thread_body
    results = []
    Cosmos::Store.instance.read_topics(@topics, @offsets) do |topic, msg_id, msg_hash, redis|
      @offsets[@offset_index_by_topic[topic]] = msg_id
      results << msg_hash
      if results.length > @max_batch_size
        transmit_results(results)
        results.clear
      end
      break if @cancel_thread
    end
    transmit_results(results)
  end

  def thread_teardown
    # Define in subclass
  end

end
