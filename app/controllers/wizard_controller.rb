# encoding: utf-8
class WizardController < ApplicationController

  before_filter :authenticate_user!

  layout 'application'

  # para el wizard de creación de campaña
  include Wicked::Wizard

  steps :first, :second

  def show
    @campaign = Campaign.find_by_slug(params[:campaign_id])
    render_wizard
  end

  def update
    @campaign = Campaign.find_by_slug(params[:campaign_id])
    params[:campaign][:wstatus] = step.to_s
    params[:campaign][:wstatus] = 'active' if step == steps.last
    @campaign.update_attributes(params[:campaign])
    if @campaign.wstatus == 'active'
      if @campaign.sub_oigame
        Mailman.send_campaign_to_sub_oigame_admin(@campaign.sub_oigame, @campaign).deliver
      else
        Mailman.send_campaign_to_social_council(@campaign).deliver
      end
    end
    render_wizard @campaign
  end

  def create
    @campaign = Campaign.create
    redirect_to new_campaign_path(:campaign_id => @campaign.slug)
  end

  private

  # no rula
  #def redirect_to_finish_wizard
  #  flash[:notice] = "Gracias por crear la campaña."
  #  redirect_to root_url
  #end
end
