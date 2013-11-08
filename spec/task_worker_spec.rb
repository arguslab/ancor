require 'spec_helper'

class ExampleTaskExecutor
  attr_accessor :task

  def context
    @task.context
  end

  def perform(*args)
    if context[:ran_once]
      true
    else
      context[:ran_once] = true
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

    subject.perform(task.id)
    task.reload.should be_completed
  end
end
