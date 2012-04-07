require 'helper'

class SampleModel < LeanModel::Base
end

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests
 
  def setup
    @model = SampleModel.new
  end
end
