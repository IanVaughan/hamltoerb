require 'test/unit'
require './lib/hamltoerb'

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
    assert_equal '<h2.icon.icon-24.icon-envelope>',                @h2r.replace_tag('%h2.icon.icon-24.icon-envelope')
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
    assert_equal '<h2 class="icon icon-24 icon-envelope">Email not verified!', @h2r.parse('%h2.icon.icon-24.icon-envelope Email not verified!')
    assert_equal "<%= link_to search_results_path(:mode => :online), 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Online Search'%>",
      @h2r.parse("%a{:href => search_results_path(:mode => :online), 'data-tracking-category' => 'Dashboard', 'data-tracking-action' => 'Online Search'}")
  end
end
