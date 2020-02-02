Dir.glob(File.join(File.dirname(__FILE__), 'test_*.rb')).sort { |file|
  require(file) unless file == __FILE__
}
