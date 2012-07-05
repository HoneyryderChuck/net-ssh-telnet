require 'net/ssh'
require 'telnet'

module Net::SSH
  class SubShell < Telnet
    def initialize(options, &block)
      # rip out the subshell-specific options
      subshell_options = options.delete "SubShell"

      super(options) {}

      # save original prompt, set new prompt, and begin subshell
      original_prompt = self.prompt
      self.prompt= subshell_options["Prompt"]
      output = self.cmd subshell_options["Cmd"]

      # run block in context of the sub-shell
      yield self, output if block_given?


      # restore prompt and exit the sub-shell
      self.prompt = original_prompt
      self.cmd "exit"
      self
    end
  end
end
