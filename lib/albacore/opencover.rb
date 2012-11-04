require 'albacore/albacoretask'

class OpenCover
  include Albacore::Task
  include Albacore::RunCommand
  
  attr_accessor :target, :targetdir, :register, :output, :nodefaultfilters, 
                :mergebyhash, :showunvisited, :returntargetcode, :returncodeoffset,
                :log, :service, :oldstyle
  attr_array :targetargs, :filters, :excludebyattribute, :excludebyfile, :coverbytest
  
  def initialize
    @nodefaultfilters = false
    @mergebyhash = false
    @showunvisited = false
    @returntargetcode = false
    @service = false
    @oldstyle = false
    
    @targetargs = []
    @filters = []
    @excludebyattribute = []
    @excludebyfile = []
    @coverbytest = []
    
    super()
  end
  
  def execute
    return unless check_for_target
  
    command_parameters = []
    command_parameters << "-target:\"#{@target}\""
    command_parameters << "-targetdir:\"#{@targetdir}\"" if @targetdir
    command_parameters << build_separated("targetargs", @targetargs, " ") unless @targetargs.empty?
    command_parameters << "-register:#{@register}" if @register
    command_parameters << "-output:\"#{@output}\"" if @output
    command_parameters << build_separated("filter", @filters, " ") unless @filters.empty?
    command_parameters << "-nodefaultfilters" if @nodefaultfilters
    command_parameters << "-mergebyhash" if @mergebyhash
    command_parameters << "-showunvisited" if @showunvisited
    command_parameters << build_returntargetcode if @returntargetcode
    command_parameters << build_separated("excludebyattribute", @excludebyattribute, ";") unless @excludebyattribute.empty?
    command_parameters << build_separated("excludebyfile", @excludebyfile, ";") unless @excludebyfile.empty?
    command_parameters << build_separated("coverbytest", @coverbytest, ";") unless @coverbytest.empty?
    command_parameters << "-log:#{@register}" if @log
    command_parameters << "-service" if @service
    command_parameters << "-oldstyle" if @oldstyle
  
    puts "Running #{command_parameters.join(" ")}"
  
    result = run_command "OpenCover.Console", command_parameters.join(" ")
    
    failure_msg = 'Code Coverage Analysis Failed. See Build Log For Detail.'
    fail_with_message failure_msg if !result
  end
  
  def check_for_target
    return true if (!@target.nil?)
    msg = 'target cannot be nil.'
    @logger.info msg
    fail
    return false
  end
  
  def build_separated(param_name, values, separator)
    value = values.join(separator)
    return "-#{param_name}:\"#{value}\""
  end
  
  def build_returntargetcode
    offset = @returncodeoffset ? ":#{returncodeoffset}" : ""
    return "-returntargetcode#{offset}"
  end
end