module Stream
  def self.start(notifications, heartrate = 20, response, remote)
    response.headers['Content-Type'] = 'text/event-stream'

    # Send 2kb of filler at beginning of request for EventSource polyfill compatibility with IE.
    # response.write(":" + Array(2049).join(" ") + "\n")
    response.stream.write ":#{' ' * 2049}\n"

    queue = []

    # Subscribe the current user to notifications.
    notifications.each do |notification|
      ActiveSupport::Notifications.subscribe("#{notification}:#{remote.remote_id}") do |name, start, finish, id, payload|
          queue << {name: name, payload: payload}
      end
    end


    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    heartbeat = Thread.new do
        loop do
          sleep heartrate.seconds
          response.stream.write "event: heartbeat\n"
        end
    end

    # Send the most recent remote information first.
    # ActiveSupport::Notifications.instrument("control:#{remote.remote_id}", {'start_at' => remote.start_at, 'status' => remote.status, 'updated_at' => remote.updated_at, 'sender_id' => 'fremote_server' }.to_json)


    # Loop until the heartbeat dies.
    while heartbeat.alive?
      sleep 0.1.seconds
      response.stream.write "event: #{queue.first[:name]}\ndata: #{queue.first[:payload]} \n\n" unless queue.count == 0
      p "$$$$$$$ Something happened." unless queue.count == 0
      queue.shift
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      notifications.each do |notification|
        ActiveSupport::Notifications.unsubscribe("#{notification}:#{remote.id}")
      end
      response.stream.close
      p "stream closed"
  end
end