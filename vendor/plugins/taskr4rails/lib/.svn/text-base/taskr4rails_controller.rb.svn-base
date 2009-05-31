class Taskr4railsController < ActionController::Base
  
  def execute
    unless Object.const_defined?("TASKR4RAILS_AUTH")
      render :text => "The taskr4rails receiver cannot be used until TASKR4RAILS_AUTH is defined. See http://code.google.com/p/ruby-taskr/wiki/Taskr4rails for help.", 
        :status => 500
      return false
    end
    
    unless request.post?
      render :text => "This is the taskr4rails receiver. It responds only to POST requests.", 
        :status => 405
      return false
    end
    
    if Object.const_defined?("TASKR4RAILS_ALLOWED_HOSTS")
      ok = TASKR4RAILS_ALLOWED_HOSTS.any? do |h|
        if h.kind_of? Regexp
          h =~ request.remote_addr
        else
          h == request.remote_addr
        end
      end
      
      unless ok
        render :text => "Remote address is not in the list of permitted hosts.",
        :status => 403
        return false
      end
    end
    
    unless params[:auth] == TASKR4RAILS_AUTH
      render :text => "Invalid auth password.",
        :status => 401
      return false
    end
    
    io = StringIO.new
    prev_stdout, prev_stderr = $stdout, $stderr
    $stdout = io
    $stderr = io
    err = false # start off assuming there's no error
    begin
      if !params[:dont_wait].blank? && params[:dont_wait] != 0 && params[:dont_wait] != '0'
        puts "Task #{params[:task_name].inspect} will be forked to its own process because the 'dont_wait' parameter was set to true."
        
        # Monkey-patch Mongrel to not remove its pid file in the child
        # See: http://geekblog.vodpod.com/?p=26
        require 'mongrel'
        Mongrel::Configurator.class_eval("def remove_pid_file; puts 'child no-op'; end")
        
        pid = fork do
          RAILS_DEFAULT_LOGGER.debug("*** Taskr4Rails -- Executing task #{params[:task_name].inspect} with Ruby code: #{params[:ruby_code]}")
          eval(params[:ruby_code]) 
        end
        
        RAILS_DEFAULT_LOGGER.debug("*** Taskr4Rails -- Task #{params[:task_name].inspect} is being forked into its own thread.")
        
        Process.detach(pid)
      else
        RAILS_DEFAULT_LOGGER.debug("*** Taskr4Rails -- Executing task #{params[:task_name].inspect} with Ruby code: #{params[:ruby_code]}")
        RAILS_DEFAULT_LOGGER.debug("*** Taskr4Rails -- Waiting for task #{params[:task_name].inspect} to complete.")
        eval(params[:ruby_code]) 
      end
    rescue => e
      puts "#{e.class}: #{e}\n\nBACKTRACE:\n#{e.backtrace.join("\n")}"
      err = true
    end
    $stdout = prev_stdout
    $stderr = prev_stderr
    output = io.string
    
    render :text => output, :status => (err ? 500 : 200)
  end
  
end
