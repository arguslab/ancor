require 'spec_helper'

module Ancor
  module Adaptor

    describe YamlBuilder do

      it 'builds a requirement model from a file containing ARML' do
        path = Rails.root.join(*%w(spec fixtures arml fullstack.yaml))

        subject.build_from path

        tracker = CountTracker.new(Goal, Role, Scenario, Channel)

        subject.commit

        tracker.should have_change(Goal, 1)
        tracker.should have_change(Role, 2)
        tracker.should have_change(Scenario, 2)
        tracker.should have_change(Channel, 3)
      end

    end

  end
end
