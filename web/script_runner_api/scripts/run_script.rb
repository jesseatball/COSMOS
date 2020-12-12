start_time = Time.now
require 'cosmos/config/config_parser'
require 'json'
require '../config/environment'

id = ARGV[0]
redis = Redis.new(url: ActionCable.server.config.cable["url"])
script = JSON.parse(redis.get("running-script:#{id}"))
scope = script['scope']
name = script['name']
disconnect = script['disconnect']
startup_time = Time.now - start_time
path = File.join(Script::DEFAULT_BUCKET_NAME, scope, 'targets', name)

def run_script_log(id, message, color = 'BLACK')
  line_to_write = Time.now.sys.formatted + " (SCRIPTRUNNER): " + message
  RunningScript.message_log.write(line_to_write + "\n", true)
  ActionCable.server.broadcast("running-script-channel:#{id}", type: :output, line: line_to_write, color: color)
  # redis.publish("running-script-channel:#{id}", JSON.generate()) # TODO: Equivalent call to broadcast?
end

run_script_log(id, "Script #{path} spawned in #{startup_time} seconds")

begin
  running_script = RunningScript.new(id, scope, name, disconnect)
  if script['test_runner']
    script['test_runner'] = JSON.parse(script['test_runner']) # Convert to hash
    running_script.parse_options(script['test_runner']['options'])
    if script['test_runner']['script']
      running_script.run_text("Cosmos::TestRunner.start(#{script['test_runner']['suite']}, #{script['test_runner']['group']}, '#{script['test_runner']['script']}')")
    elsif script['test_runner']['group']
      running_script.run_text("Cosmos::TestRunner.#{script['test_runner']['method']}(#{script['test_runner']['suite']}, #{script['test_runner']['group']})")
    else
      running_script.run_text("Cosmos::TestRunner.#{script['test_runner']['method']}(#{script['test_runner']['suite']})")
    end
  else
    running_script.run
  end

  # Subscribe to the ActionCable generated topic which is namedspaced with channel_prefix
  # (defined in cable.yml) and then the channel stream. This isn't typically how you see these
  # topics used in the Rails ActionCable documentation but this is what is happening under the
  # scenes in ActionCable. Throughout the rest of the code we use ActionCable to broadcast
  #   e.g. ActionCable.server.broadcast("running-script-channel:#{@id}", ...)
  redis.subscribe([ActionCable.server.config.cable["channel_prefix"], "cmd-running-script-channel:#{id}"].compact.join(":")) do |on|
    on.message do |channel, msg|
      parsed_cmd = JSON.parse(msg)
      run_script_log(id, "Script #{path} received command: #{msg}") unless parsed_cmd == "shutdown" or parsed_cmd["method"]
      case parsed_cmd
      when "go"
        running_script.go
      when "pause"
        running_script.pause
      when "retry"
        running_script.retry_needed
      when "step"
        running_script.step
      when "stop"
        running_script.stop
        redis.unsubscribe
      when "shutdown"
        redis.unsubscribe
      else
        if parsed_cmd["method"]
          case parsed_cmd["method"]
          when "ask_string", /^prompt_.*/
            if parsed_cmd["password"]
              running_script.user_input = parsed_cmd["password"].to_s
              running_script.continue if running_script.user_input != 'Cancel'
            else
              running_script.user_input = Cosmos::ConfigParser.handle_true_false(parsed_cmd["result"].to_s)
              run_script_log(id, "User input: #{running_script.user_input}")
              running_script.continue if running_script.user_input != 'Cancel'
            end
          when "backtrace"
            ActionCable.server.broadcast("running-script-channel:#{id}",
              { type: :script, method: :backtrace, args: JSON.generate(running_script.current_backtrace) })
          when "debug"
            run_script_log(id, "DEBUG: #{parsed_cmd["args"]}") # Log what we were passed
            running_script.debug(parsed_cmd["args"]) # debug() logs the output of the command
          else
            run_script_log(id, "ERROR: Script method not handled: #{parsed_cmd["method"]}", 'RED')
          end
        else
          run_script_log(id, "ERROR: Script command not handled: #{msg}", 'RED')
        end
      end
    end
  end
rescue Exception => err
  run_script_log(id, err.formatted, 'RED')
ensure
  begin
    # Remove running script from redis
    redis = Redis.new(url: ActionCable.server.config.cable["url"])
    script = redis.get("running-script:#{id}")
    redis.del("running-script:#{id}") if script
    running = redis.smembers("running-scripts")
    running.each do |item|
      parsed = JSON.parse(item)
      if parsed["id"].to_s == id.to_s
        redis.srem("running-scripts", item)
        break
      end
    end
    ActionCable.server.broadcast("running-script-channel:#{id}", type: :complete)
  ensure
    running_script.stop_message_log if running_script
  end
end
