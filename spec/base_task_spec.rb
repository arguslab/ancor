require 'spec_helper'

describe Ancor::BaseTask do
  it 'should raise an exception when calling perform' do
    task = Ancor::BaseTask.new
    expect {
      task.perform
    }.to raise_error NotImplementedError
  end
end
