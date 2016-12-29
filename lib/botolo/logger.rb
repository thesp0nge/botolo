require 'logger/colors'

class Logger
  def helo(app, version)
    @app = app
    info "#{app} v#{version} is starting up"
  end
  def ok(msg)
		  info(msg)
  end
  def die(msg)
    error(msg)
    Kernel.exit(-1)
  end
  def bye
    info "#{@app} is shutting down"
  end

  def err(msg)
		  error(msg)
  end

end
