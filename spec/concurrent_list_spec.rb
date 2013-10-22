require 'spec_helper'

module Ancor
  describe ConcurrentList do
    it 'supports basic array operations' do
      subject.push :a
      subject.push :b

      subject.should_not be_empty
      subject.size.should eql(2)

      subject.delete :a
      subject.size.should eql(1)
    end
  end
end
