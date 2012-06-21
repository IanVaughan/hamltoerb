class HamlToErb

  MARKUP = { tag: '%', id: '#', klass: '.', eval: '-' }

  def initialize file, debug = false
    @input = File.read(file) if File.exist? file
    @outfile = file.sub(/.haml$/, '') + '.erb'
    @debug = debug
  end

  def run
    @output = File.open(@outfile, 'w')
    @input.each_line do |line|
      @line = line.chomp!
      # pp "-#{line}"
      new_line = parse line
      # pp "+#{new_line}"
      @output << new_line
      @output << "\n" unless @new_line && @new_line.length == 0
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
      line.sub! /%(\w*(\.\w+|#\w*)?) ?/, '<\1>'
    end
    line
  end
end

if __FILE__ == $0
  require 'test/unit'

  class HamlToErbTest < Test::Unit::TestCase
    def setup
      @h2r = HamlToErb.new('index.html.haml', false)
    end

    def test_replace_tag
      assert_equal 'no section',          @h2r.replace_tag('no section')
      assert_equal '<ul>',                @h2r.replace_tag('%ul')
      assert_equal '<li.local>',          @h2r.replace_tag('%li.local')
      assert_equal '<section#dashboard>', @h2r.replace_tag('%section#dashboard')
      assert_equal '<span.icon>',         @h2r.replace_tag('%span.icon')
      assert_equal '<span.label>Local',   @h2r.replace_tag('%span.label Local')
    end

    def test_repalce_id
      assert_equal 'no section', @h2r.replace_id('no section')
      assert_equal '%section id="dashboard"', @h2r.replace_id('%section#dashboard')
    end

    def test_replace_klass
      assert_equal 'no section', @h2r.replace_klass('no section')
      assert_equal '%li class="local"', @h2r.replace_klass('%li.local')
    end

    def test_replace_eval
      assert_equal 'no section', @h2r.replace_eval('no section')[1]
      assert_equal '<% if site.supports_postcodes? %>', @h2r.replace_eval('- if site.supports_postcodes?')[1]
    end

    def test_replace_href
      assert_equal 'no section', @h2r.replace_href('no section')[1]
      assert_equal "<%= link_to search_results_path, 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Local Search'%>",
        @h2r.replace_href("%a{:href => search_results_path, 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Local Search'}")[1]
    end

    def test_parse
      assert_equal 'no section', @h2r.parse('no section')
      assert_equal '<section id="dashboard">', @h2r.parse('%section#dashboard')
      assert_equal '<ul>', @h2r.parse('%ul')
      assert_equal '<% if site.supports_postcodes? %>', @h2r.parse('- if site.supports_postcodes?')
      assert_equal '<span class="icon">', @h2r.parse('%span.icon')
      assert_equal '<span class="icon">', @h2r.parse('%span.icon')
      assert_equal '<span class="label">Local', @h2r.parse('%span.label Local')
      assert_equal "<%= link_to search_results_path(:mode => :online), 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Online Search'%>",
        @h2r.parse("%a{:href => search_results_path(:mode => :online), 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Online Search'}")
    end

  end
end
