require 'spec_helper'

module Ancor
  module Tasks
    describe Sink do

      before(:each) do
        # Have to have a backing task to cache checks
        subject.task = Task.create!
      end

      it 'does not continue until all tasks are finished' do
        task_a = Task.create!
        task_b = Task.create!

        identifiers = [task_a, task_b].map do |task|
          task.id.to_s
        end

        expect(subject.perform(identifiers)).to be_false

        task_a.update_attributes!(state: :completed)
        expect(subject.perform(identifiers)).to be_false

        task_b.update_attributes!(state: :completed)
        expect(subject.perform(identifiers)).to be_true
      end

    end
  end
end
