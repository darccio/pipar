class String
  # from http://stackoverflow.com/a/1450624
  def to_class
    chain = self.split '::'
    klass = Kernel
    chain.each do |klass_string|
      klass = klass.const_get klass_string
    end
    klass.is_a?(Class) ? klass : nil
  rescue NameError
    nil
  end
end