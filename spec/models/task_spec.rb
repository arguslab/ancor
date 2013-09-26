require 'spec_helper'

describe Task do
  it 'supports lookup of child tasks' do
    t1 = Task.create
    t2 = Task.create parent_id: t1.id
    t3 = Task.create parent_id: t1.id

    t1.children.should == [t2, t3]
  end
end
