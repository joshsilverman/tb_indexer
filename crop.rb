# libs
require 'rubygems'
require 'RMagick'
include Magick

# settings
$path = "/home/ysilver/Documents/zendo/txtbks/"
$col_count = 3
$col_width = 100
$col_y_offset = 100
$col_x_offset = 100
$even_offset = 0
$flip = false
$test = false

def main
  $path += ARGV[0] + "/"
  $path_output = $path + "output/"
  Dir::mkdir($path_output) unless FileTest::directory?($path_output)
  $path_cropped = $path_output + "cropped/"
  Dir::mkdir($path_cropped) unless FileTest::directory?($path_cropped)
  $path_tmp = $path_output + "tmp/"
  Dir::mkdir($path_tmp) unless FileTest::directory?($path_tmp)

  $col_count = ARGV[1].to_i unless ARGV[1].nil?
  $col_width = ARGV[2].to_i unless ARGV[2].nil?
  $col_y_offset = ARGV[3].to_i unless ARGV[3].nil?
  $col_x_offset = ARGV[4].to_i unless ARGV[4].nil?
  $even_offset = ARGV[5].to_i unless ARGV[5].nil?
  $flip = true if ARGV[6] == "f"
  $test = true if ARGV[7] == "t"

  crop
end

def crop
  Dir.glob($path + '/*.jpg') do |image_path|

    index = /[0-9]+/.match(image_path)
    image = Magick::Image.read(image_path).first
    image = image.rotate(180) if $flip

    (0..($col_count - 1)).each do |col_index|
      next if File.exists?("#{$path_cropped}#{index}-#{col_index}.tif")
      outfile = File.new("#{$path_tmp}#{index}-#{col_index}.jpg", "w")

      y_offset = ($col_y_offset + col_index * $col_width)
      y_offset += $even_offset if index.to_s.to_i % 2 == 0


      col = image.crop(y_offset, $col_x_offset, $col_width, image.rows)
      col.write(outfile)
      system ["convert", "#{$path_tmp}#{index}-#{col_index}.jpg", "#{$path_cropped}#{index}-#{col_index}.tif"].join(" ")
    end

    break if $test == true
  end
end

# run
main
