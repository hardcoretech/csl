# frozen_string_literal: true

class String
  def indexize
    tableize.tr("/", ":")
  end

  def typeize
    indexize.singularize.to_sym
  end
end
