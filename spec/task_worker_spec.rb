# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
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
