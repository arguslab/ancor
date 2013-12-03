require 'spec_helper'

module Ancor
  module Adaptor

    describe AdaptationEngine do
      it 'plans a deployment from the requirement model' do
        build_model

        tracker = CountTracker.new(Instance, Network)

        subject.plan

        tracker.change(Instance).should == 11
        tracker.change(Network).should == 1
      end

      private

      def build_model
        yb = YamlBuilder.new
        yb.build_from(Rails.root.join(*%w(spec fixtures arml fullstack.yaml)))
        yb.commit
      end
    end

  end
end
