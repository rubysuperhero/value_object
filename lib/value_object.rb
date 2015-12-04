class ValueObject
  attr_accessor :value_keys

  def initialize(values)
    @value_keys = []
    values.each do |k,v|
      set k, v
    end
  end

  def set(k,v)
    key = sanitize_value_key(k)
    add_if_not_a_value_key(key)
    instance_variable_set("@#{key}", v)
  end

  def method_missing(meth, *args)
    set meth, args.first
  end

  private

  def add_if_not_a_value_key(k)
    return if is_value_key?(k)
    add_value_key(k)
  end

  def add_value_key(k)
    key = sanitize_value_key(k)
    value_keys.push key
    singleton_class.class_eval{ attr_accessor key.to_sym }
  end

  def is_value_key?(k)
    value_keys.any? do |key|
      value_key_matches(key).include?(k)
    end
  end

  def sanitize_value_key(k)
    k.to_s.sub(/=+$/, '')
  end

  def value_key_matches(k)
    base = sanitize_value_key(k)
    [base, format('%s=', base)].inject([]) do |matches,key|
      key_with_at = format('@%s', key)
      matches.push(key, key.to_sym, key_with_at, key_with_at.to_sym)
    end
  end
end
