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
