require 'spec_helper'

describe Role do

  it 'validates min' do
    subject.slug = :what
    subject.min = -1
    subject.should_not be_valid
  end

  it 'validates max > min' do
    subject.slug = :what
    subject.min = 5
    subject.max = 15
    subject.should be_valid
  end

  it 'validates max < min' do
    subject.slug = :what
    subject.min = 10
    subject.max = 5
    subject.should_not be_valid
  end

end
