require 'spec_helper'

describe Ancor::BaseExecutor do
  it 'should raise an exception when calling perform' do
    task = Ancor::BaseExecutor.new
    expect {
      task.perform
    }.to raise_error NotImplementedError
  end
end
