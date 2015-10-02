
class PhotoHelper
	def initialize(root_path, options)
		@options = options || {}
		@root_path = root_path
	end

	def capture
		`raspistill -o #{self.output_path} -w 1024 -h 768 -t 50 -vf -hf`
	end

	def output_path
		if @options[:simple] == true
			self.simple_path
		else
			self.complex_path
		end
	end

	def simple_path
		File.join @root_path, 'capture.jpg'
	end

	def complex_path
		path = File.join @root_path, Time.now.iso_date
		Dir.mkdir path if !Dir.exist? path
		filename = "#{Time.now.hour}.#{Time.now.min}.#{Time.now.sec}.jpg"
		return File.join path, filename
	end
end

class Time
	def iso_date
		"#{year}-#{month}-#{day}"
	end
end