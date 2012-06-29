require 'pp'
class HamlToErb

  MARKUP = { tag: '%', id: '#', klass: '.', eval: '-' }

  def initialize file, debug = false
    @input = File.read(file) if File.exist? file
    @outfile = file.sub(/.haml$/, '') + '.erb'
    @debug = debug
  end

  def run
    output = convert @input
    save output
  end

  def convert input
    output = []
    input.each_line do |line|
      line = line.chomp!
      pp "-#{line}"
      new_line = parse line
      pp "+#{new_line}"
      output << new_line
      output << "\n" unless @new_line && @new_line.length == 0
    end
    output
  end

  def close_tags
    output.each_with_index do |line, index|
      pp line
      if line[index+1]
        if line[index].count(' ') == line[index+1].count(' ')
          line << '**close**'
        end
      end
    end
  end

  def save output
    file = File.open(@outfile, 'w')
    output.each do |line|
      file.print line
    end
  end

  def parse line
    result = replace_href(line)
    return result[1] if result[0]
    line = result[1]

    result = replace_eval(line)
    return result[1] if result[0]
    line = result[1]

    replace_tag line
    replace_id line
    replace_klass line
    line
  end

  def replace_href line
    if line.include? '%a'
      puts "**href**" if @debug
      line.sub! /%a{:href =>(.*)=>(.*)}/, '<%= link_to\1=>\2%>'
      return [true, line]
    end
    [false, line]
  end

  def replace_eval line
    if line[MARKUP[:eval]]
      puts '**eval**' if @debug
      line.sub! /-(.*)/, '<%\1 %>'
      return [true, line]
    end
    [false, line]
  end

  def replace_klass line
    if line[MARKUP[:klass]]
      puts '**klass**' if @debug
      line.sub! /\.(\w+)/, ' class="\1"'
    end
    line
  end

  def replace_id line
    if line[MARKUP[:id]]
      puts '**id**' if @debug
      line.sub! /#(\w+)/, ' id="\1"'
    end
    line
  end

  def replace_tag line
    if line[MARKUP[:tag]]
      puts '**tag**' if @debug
      # line.sub! /%(\w*(\.\w*|#\w*)*) ?/, '<\1>'
      line.sub! /%(\w*)(\.|#|)(\w*)/, '<\1\2\3>'
    end
    line
  end
end
