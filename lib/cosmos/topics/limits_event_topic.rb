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

require 'cosmos/topics/topic'

module Cosmos
  class LimitsEventTopic < Topic
    def self.write(type:, target_name:, packet_name:, item_name:, old_limits_state:, new_limits_state:, time_nsec:, message:, scope:)
      Store.instance.write_topic("#{scope}__cosmos_limits_events",
        {type: 'LIMITS_CHANGE', target_name: target_name, packet_name: packet_name,
          item_name: item_name, old_limits_state: old_limits_state, new_limits_state: new_limits_state,
          time_nsec: time_nsec, message: message})
      # The current_limits hash keeps only the current limits state of items
      # It is used by the API to determine the overall limits state
      # TODO: How do we maintain / clean this hash?
      Store.hset("#{scope}__current_limits","#{target_name}__#{packet_name}__#{item_name}", new_limits_state)
    end
  end
end