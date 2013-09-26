require 'spec_helper'

class ExampleTaskExecutor
  def perform(*)
  end
end

describe Ancor::TaskWorker do
  it 'cascades execution to child tasks' do
    t1 = Task.create class_name: ExampleTaskExecutor
    t2 = Task.create class_name: ExampleTaskExecutor, parent_id: t1.id
    t3 = Task.create class_name: ExampleTaskExecutor, parent_id: t1.id

    mock(described_class).perform_async(t2.id)
    mock(described_class).perform_async(t3.id)

    subject.perform t1.id
  end

  it 'deletes the task upon successful execution' do
    task = Task.create class_name: ExampleTaskExecutor
    id = task.id

    subject.perform id

    expect {
      Task.find id
    }.to raise_error Mongoid::Errors::DocumentNotFound
  end
end
