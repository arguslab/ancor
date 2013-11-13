class HieraController < ApplicationController
  def show
    certname = params[:certname]

    hostname = certname.split('.')[0]
    instance = Instance.where(name: hostname).first

    if instance
      data = {
        exports: Hash[instance.channel_selections.map { |s| [s.slug, s.to_hash] }],
        imports: import_selector.select(instance),
        classes: [
          instance.scenario.profile
        ],
      }

      render json: data, status: 200
    else
      render nothing: true, status: 404
    end
  end

  private

  def import_selector
    @import_selector ||= Ancor::Adaptor::ImportSelector.instance
  end
end
