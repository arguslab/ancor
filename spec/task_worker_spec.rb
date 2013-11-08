require 'spec_helper'

class ExampleTaskExecutor
  attr_accessor :task

  def context
    @task.context
  end

  def perform(*args)
    if context[:second]
      true
    elsif context[:first]
      context[:second] = true
      raise 'u wot m8'
    else
      context[:first] = true
      false
    end
  end
end

describe Ancor::TaskWorker do
  before do
    subject.jid = SecureRandom.uuid
  end

  it 'suspends tasks return without finishing' do
    task = Task.create(type: ExampleTaskExecutor)

    task.should be_pending

    subject.perform(task.id)
    task.reload.should be_suspended

    expect { subject.perform(task.id) }.to raise_error
    task.reload.should be_error

    subject.perform(task.id)
    task.reload.should be_completed
  end
end
