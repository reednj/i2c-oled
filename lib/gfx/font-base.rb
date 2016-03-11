
class Numeric
	def ord
		self.to_i
	end
end

class BitmapFont
	@width = nil
	@height = nil
	@data = nil
	@cached_bitmaps = []

	def self.height
		return @height
	end

	def self.line_height
		self.height
	end

	def self.glyph(c)
		TrueTypeGlyph.new [
			nil,		# bitmap offset
			@width,		# width
			@height,	# height
			@width + 1, # x-advance
			0,			# x-offset
			-@height	# y-offset
		]
	end

	def self.char_bitmap(c)

		index = c.ord
		return @cached_bitmaps[index] if !@cached_bitmaps[index].nil?

		# the font data is encoded with 5 bytes for each character
		# each byte represents a column of 8 bits. 
		raw = @data[(index * @width)...((index + 1) * @width)]
		
		# The GFX library expects
		# a flat array of integers that are either zero or one that can
		# directly be looped through and passed to set_pixel, so we do that
		# mapping here
		bitmap = Bitmap.new(@width, height)

		(0..height).each do |y|
			raw.each_with_index do |byte, x|
				bit = (byte >> y) & 0x01
				bitmap.set(x, y, bit)
			end
		end

		@cached_bitmaps[index] = bitmap

		return bitmap
	end

end

class TrueTypeFont
	@data = nil
	@glyphs = nil
	@first_char = nil
	@last_char = nil
	@y_advance = nil

	def self.height
		self.glyph('M').height
	end

	def self.line_height
		@y_advance
	end

	def self.glyph(c)
		TrueTypeGlyph.new @glyphs[glyph_index c]
	end

	def self.glyph_data(g)
		length_bytes = (g.width * g.height / 8).ceil
		@data[g.bitmap_offset..(g.bitmap_offset + length_bytes)]
	end

	def self.glyph_index(c)
		c.ord - @first_char
	end

	def self.bytes_to_bits(bytes)
		bits = []

		bytes.each do |byte|
			(0..7).each do |i|
				b = 7 - i
				bits.push((byte >> b) & 0x01)
			end
		end
		
		return bits
	end

	def self.char_bitmap(c)

		g = glyph(c)
		raw = glyph_data(g)
		bits = bytes_to_bits(raw)

		bitmap = Bitmap.new(g.width, g.height)

		(0...bitmap.height).each do |y|
			(0...bitmap.width).each do |x|
				bit = bits[x + y * bitmap.width]
				bitmap.set x, y, bit
			end
		end

		return bitmap
	end
end

class TrueTypeGlyph
	def initialize(data)
		raise 'data required to initialize glyph' if data.nil?
		@data = data
	end

	# Pointer into GFXfont->bitmap
	def bitmap_offset
		@data[0]
	end

	# Bitmap dimensions in pixels
	def width
		@data[1]
	end

	def height
		@data[2]
	end

	# Distance to advance cursor (x axis) 
	def x_advance
		@data[3]
	end

	# Dist from cursor pos to UL corner
	def x_offset
		@data[4]
	end

	def y_offset
		@data[5]
	end 
end


class Bitmap
	attr_accessor :width
	attr_accessor :height

	def initialize(width, height)
		self.width = width.round.to_i
		self.height = height.round.to_i
		@data = (0...(self.width * self.height)).map { |i| 0 }
		@scaled_cache = {}
	end

	def data
		@data
	end

	def get(x, y)
		@data[x + y * width] || 0
	end

	def set(x, y, bit)
		@data[x + y * width] = bit
	end

	def scale(s)
		return self if s == 1.0
		return @scaled_cache[scale_key(s)] if !@scaled_cache[scale_key(s)].nil?

		bitmap = Bitmap.new(self.width * s, self.height * s)

		(0...bitmap.width).each do |xx|
			(0...bitmap.height).each do |yy|
				x = (xx / s).floor
				y = (yy / s).floor

				bitmap.set xx, yy, self.get(x, y)
			end
		end

		# turns out that scaling the bitmap takes quite a bit of time when
		# rendering text, so we keep a cache of the scaled bitmaps that 
		# can be returned immediately
		@scaled_cache[scale_key(s)] = bitmap
		return bitmap
	end

	def scale_key(s)
		"x#{s.to_f.round(2).to_s}"
	end
end