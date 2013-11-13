require 'spec_helper'

module Ancor
  module Adaptor

    describe YamlBuilder do

      it 'builds a requirement model from a file containing ARML' do
        path = Rails.root.join(*%w(spec fixtures arml fullstack.yaml))

        subject.build_from path

        tracker = CountTracker.start(Goal, Role, Scenario, Channel)

        subject.commit

        tracker[Goal].should == 1
        tracker[Role].should == 2
        tracker[Scenario].should == 2
        tracker[Channel].should == 3
      end

    end

  end
end
