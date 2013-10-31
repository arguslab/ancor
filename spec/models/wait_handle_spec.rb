require 'spec_helper'

describe WaitHandle do
  it 'supports querying for simple task associations' do
    task = Task.create

    wh = WaitHandle.new(type: :test, correlations: { 'some_id' => 'id' })
    wh.tasks << task
    wh.save

    ct = WaitHandle.correlated_tasks(:test, some_id: 'id')
    ct.should == [task.id.to_s]
  end

  it 'supports querying for complex task associations' do
    task_a = Task.create
    task_b = Task.create
    task_c = Task.create

    wh_a = WaitHandle.new(type: :test, correlations: { 'some_id' => 'id' })
    wh_a.tasks << task_a << task_b
    wh_a.save

    wh_b = WaitHandle.new(type: :test, correlations: { 'some_id' => 'id' })
    wh_b.tasks << task_c
    wh_b.save

    ct = WaitHandle.correlated_tasks(:test, some_id: 'id')
    ct.should == [task_a, task_b, task_c].map { |t| t.id.to_s }
  end
end
