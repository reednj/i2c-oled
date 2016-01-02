require './lib/gfx/fonts'

module DisplayGFX
	attr_accessor :fill_color
	attr_accessor :font_size
	attr_accessor :line_width
	attr_accessor :text_align

	attr_reader :font

	# check the type when setting the font - we need a char_bitmap method to convert it
	# to something that can be rendered
	def font=(f)
		raise 'Font must respond to char_bitmap' if !f.nil? && !f.respond_to?(:char_bitmap)
		@font = f
	end

	def initialize(*args)
		self.fill_color = 0
		self.font = ClassicFont
		self.font_size = 1
		self.line_width = 1
		self.text_align = :center
	end
	
	def fill_rect(x, y, w, h)
		(x...(x + w)).each do |xx|
			(y...(y + h)).each do |yy|
				self.set_pixel(xx, yy, fill_color)
			end
		end
	end

	def fill_text(x, y, text)
		raise 'no font selected' if self.font.nil?

		# by default (x,y) will be the top right corner of the 
		# text, but it is useful to have it be the middle or the
		# top right
		#
		# these adjust the coords back to the top left position
		# based off what the text align was set to
		if self.text_align != :left
			text_size = self.measure_text text

			if self.text_align == :center
				x = x - text_size[:width] / 2
			elsif self.text_align == :right
				x = x - text_size[:width]
			end
		end

		x_offset = 0
		text.to_s.split('').each_with_index do |c, i|
			self.fill_char(x + x_offset, y, c)
			x_offset += self.font.glyph(c).x_advance * self.font_size
		end
	end

	def fill_char(x, y, c)
		raise 'no font selected' if self.font.nil?
		
		# for the true-type fonts we need to use the y-offset to make sure
		# that the baseline is aligned properly
		glyph = self.font.glyph c
		y += glyph.y_offset * self.font_size
		x += glyph.x_offset * self.font_size

		bitmap = self.font.char_bitmap c.ord
		bitmap = bitmap.scale self.font_size
		self.draw_bitmap(x, y, bitmap)
	end

	def draw_bitmap(x, y, bitmap)
		raise 'needs bitmap needs to be of type Bitmap' if !bitmap.is_a? Bitmap

		(0...bitmap.width).each do |xx|
			(0...bitmap.height).each do |yy|
				bit = bitmap.get xx, yy
				set_pixel(x + xx, y + yy, self.fill_color) if bit > 0
			end
		end
	end

	def measure_text(text)
		text_width = text.split('').map{|c| self.font.glyph(c).x_advance }.reduce(0, :+)

		return {
			:width => text_width * self.font_size,
			:height => self.font.height * self.font_size
		}
	end

	def display_center
		return {
			:x => (self.width / 2).floor,
			:y => (self.height / 2).floor
		}
	end

end
