class HealthDataController < ApplicationController
  before_action :authenticate_user!, :only => [:data_explore, :data_reports, :medications]
  before_action :set_active_top_nav_link_to_health_data
  before_action :validate_oodt_module, :only => [:explore, :reports]
  before_action :validate_validic_module, :only => []

  layout "community"

  def validate_oodt_module
    raise "OODT must be enabled for this feature." if !Figaro.env.oodt_enabled
  end

  def validate_validic_module
    raise "Validic must be enabled for this feature." if !Figaro.env.validic_enabled
  end

  def index
    @med_list = (current_user and ENV["oodt_enabled"]) ? current_user.get_med_list : {}
    check_in
  end

  def submit_check_in
    params[:question_id]
    params[:value]
  end


  private

  def check_in
    @question_flow = QuestionFlow.find_by_name_en("Daily Trends")
    @answer_session = AnswerSession.most_recent(@question_flow.id, current_user.id)


    if @answer_session.nil? or (@answer_session.completed? and (Time.zone.now - @answer_session.updated_at).hours >= Figaro.env.daily_trend_frequency.to_i) or params[:new_daily_trends]
      AnswerSession.create(user_id: current_user.id, question_flow_id: @question_flow.id)
    end


    #@check_in_questions = Group.find_by_name("Health Data Check In").questions


  end
end
