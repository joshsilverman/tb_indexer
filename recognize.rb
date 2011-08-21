# libs
require 'rubygems'
require 'RMagick'
include Magick

# settings
$path = "/home/ysilver/Documents/zendo/txtbks/"
$test = false

def main
  $path += ARGV[0] + "/"
  $path_output = $path + "output/"
  Dir::mkdir($path_output) unless FileTest::directory?($path_output)
  $path_cropped = $path_output + "cropped/"
  Dir::mkdir($path_cropped) unless FileTest::directory?($path_cropped)
  $path_text = $path_output + "text/"
  Dir::mkdir($path_text) unless FileTest::directory?($path_text)


  $test = true if ARGV[1] == "t"

  recognize
end

def recognize
  Dir.glob("#{$path_cropped}*.tif") do |image_path|
    index = /[0-9]+-[0-9]+/.match(image_path).to_s
    text_path = $path_text + index
    image = Magick::Image.read(image_path).first
    system ["tesseract", image_path, text_path, "&"].join(" ")
    break if $test
  end
end

# run
main
