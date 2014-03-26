class NullJob
  include SuckerPunch::Job

  def perform
  	sleep 2
	p "Here I am."  
  end
end
