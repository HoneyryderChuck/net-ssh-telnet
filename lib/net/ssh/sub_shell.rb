require 'telnet'

module Net::SSH
  class SubShell < Telnet
    def initialize(options, &block)
      sub_options = options.delete "SubShell"
      super(options)
      original_prompt = self.prompt
      self.prompt= sub_options["prompt"]
      self.cmd sub_options["cmd"]
      yield block
      self.prompt = original_prompt
      self.cmd "exit"
    end
  end
end
