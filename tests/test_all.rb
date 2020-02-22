Dir.glob(File.join(File.dirname(__FILE__), 'test_*.rb')).sort do |file|
  require(file) unless file == __FILE__
end
