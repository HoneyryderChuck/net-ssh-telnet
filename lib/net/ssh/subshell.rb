require 'net/ssh'
require 'net/ssh/telnet'

module Net::SSH
  class SubShell
    attr_accessor :connection, :options
    attr_reader :original_prompt

    def initialize(conn, cmd, options={})
      @connection=
          if conn.is_a? Net::SSH::Connection::Session
            Net::SSH::Telnet.new("Session" => conn)
          elsif conn.is_a? Net::SSH::Telnet
            conn
          else
            Net::SSH::Telnet.new(conn)
          end

      @options= defaults.merge(options)

      if block_given?
        original_prompt= connection.prompt
        @connection.prompt= @options[:prompt]
        output= connection.cmd cmd
        yield self, output
        @connection.prompt= original_prompt
        @connection.cmd "exit"
      end
    end

    def cmd(*args)
      @connection.cmd *args
    end

    def defaults
      {:prompt => /[$%#>] \z/n, :exit => "exit"}
    end

  end
end
