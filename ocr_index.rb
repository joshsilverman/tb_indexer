# settings
$path = "/home/ysilver/Documents/zendo/txtbks/"
$text = ""
$terms = []
$chapters = []
$chapters_with_terms = []

def main
  $path += ARGV[0] + "/"
  $path_output = $path + "output/"
  Dir::mkdir($path_output) unless FileTest::directory?($path_output)
  $path_text = $path_output + "text/"
  Dir::mkdir($path_text) unless FileTest::directory?($path_text)
  $path_index = $path_output + "index/"
  Dir::mkdir($path_index) unless FileTest::directory?($path_index)

  # chapter breaks
  ARGV.each_with_index {|arg, i| $chapters << arg.to_i unless i == 0}

  index
  sort
  to_html
end

def index
  text_pages = Array.new
  Dir.glob("#{$path_text}*.txt") do |txt_path|
    index = /([0-9]+)-([0-9]+)/.match(txt_path)
    index = index[1].to_i * 10 + index[2].to_i
    text_pages.push(:index => index, :text => File.read(txt_path))
  end

  text_pages = text_pages.sort_by {|page| page[:index]}
  text_pages.each {|page| $text += page[:text]}
end

def sort
  lines = $text.split("\n")
  lines.each_with_index do |line, i|
    pages = /([0-9]+[0-9,\-\s]*)/.match(line).to_s.gsub(/\s/, "").gsub(/-[0-9]+/, "").split(",")
    term = line.split(/([0-9]+[0-9,\-\s]*)/)[0]

    if term
      term.gsub!(/^(?:of|vs.|and|in)\s/, "")
      term.gsub!(/(?:,|in,|on)\s*$/, "")
      term.gsub!(/\([^)]+\)/, "")
      term.gsub!(/.* of\s*$/, "")
      term.gsub!(/^of\s*$/, "")

      term.gsub!(/\s+/, " ")
      term.gsub!(/^\s+|\s+$/, " ")
    end

    term_temp = term.split(", ") if term
    if term_temp and term_temp.length == 2 and term_temp[0][0] and term_temp[1][0]
      term = "#{term_temp[1]} #{term_temp[0]}"
    end

    pages.each {|page| $terms.push({:page => page.to_i, :term => term}) if term}
  end
  $terms = $terms.sort_by {|term| term[:page]}

  # chapters
  i = -1
  $terms.each do |term|
    if $chapters[0] and term[:page] >= $chapters[0]
      i += 1
      $chapters.shift
      $chapters_with_terms[i] = []
      $chapters_with_terms[i] << term if ($chapters_with_terms[i].find_all {|t| t[:term] == term[:term]}).length == 0
    end
    $chapters_with_terms[i] << term
  end
end

def to_html
  html = ""
  $chapters_with_terms.each_with_index do |terms, i|
    tmp_terms = []
    html += "</ul>Chapter #{i + 1}<ul>"
    terms.each do |term|
      next unless tmp_terms.index(term[:term]).nil?
      tmp_terms << term[:term]
      html += "<li><strong>#{term[:term]}</strong></strong> (#{term[:page]})</li>"
    end
  end

  html = "<html><body>#{html}</body></html>"

  File.open("#{$path_index}index.htm", 'w') {|f| f.write(html) }
end

# run
main
