require 'spec_helper'

describe Role do

  it 'validates fields in roles' do
    subject.slug = :what

    #subject.min = -1
    #subject.should_not be_valid

    #subject.min = 1
    subject.max = 15
    #subject.should be_valid


    subject.min = 20
    subject.should_not be_valid

  end
end
