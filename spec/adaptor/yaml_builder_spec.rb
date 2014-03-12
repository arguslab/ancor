require 'spec_helper'

module Ancor
  module Adaptor

    describe YamlBuilder do
      subject { YamlBuilder.new(environment) }
      let(:environment) { Environment.new }

      it 'builds a requirement model from a file containing ARML' do
        path = Rails.root.join('spec/fixtures/arml/fullstack.yaml')

        subject.build_from path

        tracker = CountTracker.new(Goal, Role, Scenario, Channel)

        subject.commit

        tracker.change(Goal).should == 1
        tracker.change(Role).should == 6
        tracker.change(Scenario).should == 6
        tracker.change(Channel).should == 5
      end

    end

  end
end
