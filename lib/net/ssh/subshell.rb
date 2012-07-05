require 'net/ssh'
require 'net/ssh/telnet'

module Net::SSH
  class SubShell
    attr_accessor :connection, :options
    attr_reader :original_prompt

    def initialize(connection, cmd=nil, options={}, &block)
      @connection= tunnel(connection)
      @options= defaults.merge(options)

      run(cmd, &block) unless cmd.nil?
    end

    def run(cmd, &block)
      @original_prompt= @connection.prompt
      @connection.prompt= @options[:prompt]
      output= @connection.cmd(cmd)
      if block_given?
        yield self, output
        exit
      end
      self
    end

    def cmd(*args)
      @connection.cmd *args
    end

    def exit
      @connection.prompt= @original_prompt
      @connection.cmd @options[:exit]
    end

    def defaults
      {:prompt => /[$%#>] \z/n, :exit => "exit"}
    end

    private
    def tunnel(conn)
      if conn.is_a? Net::SSH::Connection::Session
        Net::SSH::Telnet.new("Session" => conn)
      elsif conn.is_a? Net::SSH::Telnet
        conn
      elsif conn.is_a? Net::SSH::SubShell
        conn.connection
      else
        Net::SSH::Telnet.new(conn)
      end
    end

  end
end
