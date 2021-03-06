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

require 'cosmos/models/router_model'
require 'cosmos/models/router_status_model'
require 'cosmos/topics/router_topics'

module Cosmos
  module Api
    WHITELIST ||= []
    WHITELIST.concat([
      'get_router_names',
      'connect_router',
      'disconnect_router',
      'router_state',
      'get_router_info',
      'get_all_router_info',
    ])

    # @return [Array<String>] All the router names
    def get_router_names(scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system', scope: scope, token: token)
      RouterModel.names(scope: scope)
    end

    # Connects a router and starts its command gathering thread. If
    # optional parameters are given, the router is recreated with new
    # parameters.
    #
    # @param router_name [String] The name of the router
    # @param params [Array] Parameters to pass to the router.
    def connect_router(router_name, *params, scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system_set', router_name: router_name, scope: scope, token: token)
      RouterTopics.connect_router(router_name, scope: scope)
    end

    # Disconnects a router and kills its command gathering thread
    #
    # @param router_name (see #connect_router)
    def disconnect_router(router_name, scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system_set', router_name: router_name, scope: scope, token: token)
      RouterTopics.disconnect_router(router_name, scope: scope)
    end

    # @param router_name (see #connect_router)
    # @return [String] The state of the router which is one of 'CONNECTED',
    #   'ATTEMPTING' or 'DISCONNECTED'.
    def router_state(router_name, scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system', router_name: router_name, scope: scope, token: token)
      RouterStatusModel.get(name: router_name, scope: scope)['state']
    end

    # Get information about a router
    #
    # @param router_name [String] Router name
    # @return [Array<String, Numeric, Numeric, Numeric, Numeric, Numeric,
    #   Numeric, Numeric>] Array containing \[state, num clients,
    #   TX queue size, RX queue size, TX bytes, RX bytes, Pkts received,
    #   Pkts sent] for the router
    def get_router_info(router_name, scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system', router_name: router_name, scope: scope, token: token)
      int = RouterStatusModel.get(name: router_name, scope: scope)
      return [int['state'], int['clients'], int['txsize'], int['rxsize'],
              int['txbytes'], int['rxbytes'], int['rxcnt'], int['txcnt']]
    end

    # Get information about all routers
    #
    # @return [Array<Array<String, Numeric, Numeric, Numeric, Numeric, Numeric,
    #   Numeric, Numeric>>] Array of Arrays containing \[name, state, num clients,
    #   TX queue size, RX queue size, TX bytes, RX bytes, Command count,
    #   Telemetry count] for all routers
    def get_all_router_info(scope: $cosmos_scope, token: $cosmos_token)
      authorize(permission: 'system', scope: scope, token: token)
      info = []
      RouterStatusModel.all(scope: scope).each do |int_name, int|
        info << [int['name'], int['state'], int['clients'], int['txsize'], int['rxsize'],\
                  int['txbytes'], int['rxbytes'], int['rxcnt'], int['txcnt']]
      end
      info.sort! {|a,b| a[0] <=> b[0] }
      info
    end

  end
end