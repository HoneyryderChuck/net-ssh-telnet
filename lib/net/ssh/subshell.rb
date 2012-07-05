require 'net/ssh'
require 'net/ssh/telnet'

module Net::SSH
  class SubShell
    attr_accessor :connection, :options
    attr_reader :original_prompt, :last_output

    def initialize(connection, cmd=nil, options={}, &block)
      @connection= tunnel(connection)
      @options= defaults.merge(options)

      run(cmd, &block) unless cmd.nil?
    end

    def run(cmd, &block)
      @original_prompt= @connection.prompt
      @connection.prompt= Regexp.union(@options[:prompt], @original_prompt)
      output= @connection.cmd(cmd)
      if block_given?
        yield self, output
        exit
      end
      self
    end

    def cmd(*args)
      @last_output = @connection.cmd *args
    end

    def exit
      @connection.prompt= @original_prompt
      @connection.cmd @options[:exit] unless @last_output.match(@original_prompt)
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

    #############################
    ### Specialized SubShells ###
    #############################

    class SqlPlus < SubShell
      def defaults
        super.merge({:prompt => /SQL> \z/n})
      end

      def run_script(script)
        cmd "@" + script
      end
    end

  end
end
