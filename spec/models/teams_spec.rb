require 'rails_helper'

RSpec.describe Team, type: :model do
  it 'is invalid with required field missing' do
    expect(FactoryGirl.build(:team, team_name: nil)).not_to be_valid
  end

  it '.to_csv' do
    adviser_user = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid1.team.model.spec')
    mentor_user = FactoryGirl.create(:user, email: 'user2@team.model.spec', uid: 'uid2.team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: adviser_user)
    mentor = FactoryGirl.create(:mentor, user: mentor_user)
    team1 = FactoryGirl.create(:team, team_name: '1.team.model.spec', adviser: adviser, mentor: mentor)
    student1_user = FactoryGirl.create(:user, email: 'user3@team.model.spec', uid: 'uid3.team.model.spec')
    student2_user = FactoryGirl.create(:user, email: 'user4@team.model.spec', uid: 'uid4.team.model.spec')
    FactoryGirl.create(:student, user: student1_user, team: team1)
    FactoryGirl.create(:student, user: student2_user, team: team1)
    require 'csv'
    csv = CSV.parse(Team.to_csv)
    expect(csv.first).to eql ['Team ID', 'Team Name', 'Project Level', 'Has Dropped', 'Student 1 UserID',
                              'Student 1 Name', 'Student 1 Email', 'Student 2 UserID', 'Student 2 Name',
                              'Student 2 Email', 'Adviser UserID', 'Adviser Name', 'Mentor UserID', 'Mentor Name',
                              'Average PE Score']
  end

  it '#set_project_level' do
    team1 = FactoryGirl.build(:team)
    team1.set_project_level('vostok')
    expect(team1.vostok?).to be true
    team1.set_project_level('project gemini')
    expect(team1.project_gemini?).to be true
    team1.set_project_level('apollo 11')
    expect(team1.apollo_11?).to be true
    team1.set_project_level('v')
    expect(team1.vostok?).to be true
    team1.set_project_level('gemini')
    expect(team1.project_gemini?).to be true
    team1.set_project_level('apollo')
    expect(team1.apollo_11?).to be true
  end

  it '#get_relevant_users' do
    user1 = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid1@team.model.spec')
    user_not_related = FactoryGirl.create(:user, email: 'user2@team.model.spec', uid: 'uid2@team.model.spec')
    user_teammate = FactoryGirl.create(:user, email: 'user3@team.model.spec', uid: 'uid3@team.model.spec')
    user_evaluated = FactoryGirl.create(:user, email: 'user4@team.model.spec', uid: 'uid4@team.model.spec')
    user_evaluator = FactoryGirl.create(:user, email: 'user5@team.model.spec', uid: 'uid5@team.model.spec')
    user_adviser = FactoryGirl.create(:user, email: 'user6@team.model.spec', uid: 'uid6@team.model.spec')
    user_mentor = FactoryGirl.create(:user, email: 'user7@team.model.spec', uid: 'uid7@team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: user_adviser)
    mentor = FactoryGirl.create(:mentor, user: user_mentor)
    team1 = FactoryGirl.create(:team, team_name: 'team_1.team.model.spec', adviser: adviser, mentor: mentor)
    team_evaluated = FactoryGirl.create(:team, team_name: 'team_2.team.model.spec', adviser: adviser)
    team_evaluator = FactoryGirl.create(:team, team_name: 'team_3.team.model.spec', adviser: adviser)
    FactoryGirl.create(:evaluating, evaluated: team_evaluated, evaluator: team1)
    FactoryGirl.create(:evaluating, evaluated: team1, evaluator: team_evaluator)
    FactoryGirl.create(:student, user: user1, team: team1)
    FactoryGirl.create(:student, user: user_not_related, team: nil)
    FactoryGirl.create(:student, user: user_teammate, team: team1)
    FactoryGirl.create(:student, user: user_evaluated, team: team_evaluated)
    FactoryGirl.create(:student, user: user_evaluator, team: team_evaluator)

    closely_related = team1.get_relevant_users
    expect(closely_related.length).to eql 4
    expect(closely_related).to include user1
    expect(closely_related).to include user_teammate
    expect(closely_related).to include user_adviser
    expect(closely_related).to include user_mentor
    related = team1.get_relevant_users(true, false)
    expect(related.length).to eql 5
    expect(related).to include user1
    expect(related).to include user_teammate
    expect(related).to include user_adviser
    expect(related).to include user_mentor
    expect(related).to include user_evaluator
    related = team1.get_relevant_users(false, true)
    expect(related.length).to eql 5
    expect(related).to include user1
    expect(related).to include user_teammate
    expect(related).to include user_adviser
    expect(related).to include user_mentor
    expect(related).to include user_evaluated
  end

  it '#get_own_submissions' do
    milestone1 = FactoryGirl.create(:milestone, name: '1.team.model.spec')
    milestone2 = FactoryGirl.create(:milestone, name: '2.team.model.spec')
    milestone3 = FactoryGirl.create(:milestone, name: '3.team.model.spec')
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec')
    team_with_no_submissions = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    submission1 = FactoryGirl.create(:submission, team: team, milestone: milestone1)
    submission2 = FactoryGirl.create(:submission, team: team, milestone: milestone2)
    team_submissions = team.get_own_submissions
    expect(team_submissions.length).to eql 2
    expect(team_submissions.keys).to include milestone1.id
    expect(team_submissions[milestone1.id]).to eql submission1
    expect(team_submissions.keys).to include milestone2.id
    expect(team_submissions[milestone2.id]).to eql submission2
    expect(team_submissions[milestone3.id]).to be_nil
    expect(team_with_no_submissions.get_own_submissions.length).to eql 0
  end

  it '#get_others_submissions' do
    milestone1 = FactoryGirl.create(:milestone, name: '1.team.model.spec')
    milestone2 = FactoryGirl.create(:milestone, name: '2.team.model.spec')
    milestone3 = FactoryGirl.create(:milestone, name: '3.team.model.spec')
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec')
    team_evaluated1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluated2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluated3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    evaluating1 = FactoryGirl.create(:evaluating, evaluated: team_evaluated1, evaluator: team)
    evaluating2 = FactoryGirl.create(:evaluating, evaluated: team_evaluated2, evaluator: team)
    evaluating3 = FactoryGirl.create(:evaluating, evaluated: team_evaluated3, evaluator: team)
    submission1 = FactoryGirl.create(:submission, team: team_evaluated1, milestone: milestone1)
    submission2 = FactoryGirl.create(:submission, team: team_evaluated1, milestone: milestone2)
    submission3 = FactoryGirl.create(:submission, team: team_evaluated2, milestone: milestone1)
    evaluated_teams_submissions_hash = team.get_others_submissions
    expect(evaluated_teams_submissions_hash.length).to eql 3
    expect(evaluated_teams_submissions_hash.keys).to include milestone1.id
    expect(evaluated_teams_submissions_hash[milestone1.id].length).to eql 3
    expect(evaluated_teams_submissions_hash[milestone1.id][evaluating1.id]).to eql submission1
    expect(evaluated_teams_submissions_hash[milestone1.id][evaluating2.id]).to eql submission3
    expect(evaluated_teams_submissions_hash[milestone1.id][evaluating3.id]).to be_nil
    expect(evaluated_teams_submissions_hash.keys).to include milestone2.id
    expect(evaluated_teams_submissions_hash[milestone2.id].length).to eql 3
    expect(evaluated_teams_submissions_hash[milestone2.id][evaluating1.id]).to eql submission2
    expect(evaluated_teams_submissions_hash[milestone2.id][evaluating2.id]).to be_nil
    expect(evaluated_teams_submissions_hash[milestone2.id][evaluating3.id]).to be_nil
    expect(evaluated_teams_submissions_hash.keys).to include milestone3.id
    expect(evaluated_teams_submissions_hash[milestone3.id].length).to eql 3
    expect(evaluated_teams_submissions_hash[milestone3.id][evaluating1.id]).to be_nil
    expect(evaluated_teams_submissions_hash[milestone3.id][evaluating2.id]).to be_nil
    expect(evaluated_teams_submissions_hash[milestone3.id][evaluating3.id]).to be_nil
  end

  it '#get_own_evaluations_for_others' do
    milestone1 = FactoryGirl.create(:milestone, name: '1.team.model.spec')
    milestone2 = FactoryGirl.create(:milestone, name: '2.team.model.spec')
    milestone3 = FactoryGirl.create(:milestone, name: '3.team.model.spec')
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec')
    team_evaluated1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluated2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluated3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    FactoryGirl.create(:evaluating, evaluated: team_evaluated1, evaluator: team)
    FactoryGirl.create(:evaluating, evaluated: team_evaluated2, evaluator: team)
    FactoryGirl.create(:evaluating, evaluated: team_evaluated3, evaluator: team)
    submission1 = FactoryGirl.create(:submission, team: team_evaluated1, milestone: milestone1)
    submission2 = FactoryGirl.create(:submission, team: team_evaluated1, milestone: milestone2)
    submission3 = FactoryGirl.create(:submission, team: team_evaluated2, milestone: milestone1)
    submission4 = FactoryGirl.create(:submission, team: team_evaluated3, milestone: milestone3)
    peer_eval1 = FactoryGirl.create(:peer_evaluation, team: team, submission: submission1)
    peer_eval2 = FactoryGirl.create(:peer_evaluation, team: team, submission: submission2)
    peer_eval3 = FactoryGirl.create(:peer_evaluation, team: team, submission: submission3)
    peer_eval4 = FactoryGirl.create(:peer_evaluation, team: team, submission: submission4)
    own_peer_evals_hash = team.get_own_evaluations_for_others
    expect(own_peer_evals_hash.length).to eql 4
    expect(own_peer_evals_hash[submission1.id]).to eql peer_eval1
    expect(own_peer_evals_hash[submission2.id]).to eql peer_eval2
    expect(own_peer_evals_hash[submission3.id]).to eql peer_eval3
    expect(own_peer_evals_hash[submission4.id]).to eql peer_eval4
  end

  it '#get_evaluations_for_own_team' do
    milestone1 = FactoryGirl.create(:milestone, name: '1.team.model.spec')
    milestone2 = FactoryGirl.create(:milestone, name: '2.team.model.spec')
    milestone3 = FactoryGirl.create(:milestone, name: '3.team.model.spec')
    user_adviser = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid6@team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: user_adviser)
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec', adviser: adviser)
    team_evaluator1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluator2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluator3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    evaluating1 = FactoryGirl.create(:evaluating, evaluator: team_evaluator1, evaluated: team)
    evaluating2 = FactoryGirl.create(:evaluating, evaluator: team_evaluator2, evaluated: team)
    evaluating3 = FactoryGirl.create(:evaluating, evaluator: team_evaluator3, evaluated: team)
    submission1 = FactoryGirl.create(:submission, team: team, milestone: milestone1)
    submission2 = FactoryGirl.create(:submission, team: team, milestone: milestone2)
    peer_eval1 = FactoryGirl.create(:peer_evaluation, team: team_evaluator1, submission: submission1)
    peer_eval2 = FactoryGirl.create(:peer_evaluation, team: team_evaluator2, submission: submission1)
    peer_eval3 = FactoryGirl.create(:peer_evaluation, team: team_evaluator3, submission: submission1)
    peer_eval4 = FactoryGirl.create(:peer_evaluation, team: team_evaluator1, submission: submission2)
    peer_eval5 = FactoryGirl.create(:peer_evaluation, team: team_evaluator2, submission: submission2)
    peer_eval6 = FactoryGirl.create(:peer_evaluation, adviser: adviser, submission: submission2)

    peer_evals_hash = team.get_evaluations_for_own_team
    expect(peer_evals_hash.length).to eql 3
    expect(peer_evals_hash[milestone1.id][evaluating1.id]).to eql peer_eval1
    expect(peer_evals_hash[milestone1.id][evaluating2.id]).to eql peer_eval2
    expect(peer_evals_hash[milestone1.id][evaluating3.id]).to eql peer_eval3
    expect(peer_evals_hash[milestone1.id][:adviser]).to be_nil

    expect(peer_evals_hash[milestone2.id][evaluating1.id]).to eql peer_eval4
    expect(peer_evals_hash[milestone2.id][evaluating2.id]).to eql peer_eval5
    expect(peer_evals_hash[milestone2.id][evaluating3.id]).to be_nil
    expect(peer_evals_hash[milestone2.id][:adviser]).to eql peer_eval6

    expect(peer_evals_hash[milestone3.id][evaluating1.id]).to be_nil
    expect(peer_evals_hash[milestone3.id][evaluating2.id]).to be_nil
    expect(peer_evals_hash[milestone3.id][evaluating3.id]).to be_nil
    expect(peer_evals_hash[milestone3.id][:adviser]).to be_nil
  end

  it '#get_feedbacks_for_others' do
    user_adviser = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid6@team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: user_adviser)
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec', adviser: adviser)
    team_evaluator1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluator2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluator3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    evaluating1 = FactoryGirl.create(:evaluating, evaluator: team_evaluator1, evaluated: team)
    evaluating2 = FactoryGirl.create(:evaluating, evaluator: team_evaluator2, evaluated: team)
    evaluating3 = FactoryGirl.create(:evaluating, evaluator: team_evaluator3, evaluated: team)
    survey_template1 = FactoryGirl.create(:survey_template, survey_type: 2)
    feedback1 = FactoryGirl.create(:feedback, team: team, target_team: team_evaluator1,
                                   survey_template: survey_template1, response_content: '{"1": "0"}')
    feedback2 = FactoryGirl.create(:feedback, team: team, target_team: team_evaluator2,
                                   survey_template: survey_template1, response_content: '{"1": "2"}')
    feedbacks = team.get_feedbacks_for_others
    expect(feedbacks.length).to eql 3
    expect(feedbacks[evaluating1.id]).to eql feedback1
    expect(feedbacks[evaluating2.id]).to eql feedback2
    expect(feedbacks[evaluating3.id]).to be_nil
  end

  it '#get_average_evaluation_ratings' do
    milestone1 = FactoryGirl.create(:milestone, name: 'Milestone 1')
    milestone2 = FactoryGirl.create(:milestone, name: 'Milestone 2')
    milestone3 = FactoryGirl.create(:milestone, name: 'Milestone 3')
    user_adviser = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid6@team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: user_adviser)
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec', adviser: adviser)
    team_evaluator1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluator2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluator3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    FactoryGirl.create(:evaluating, evaluator: team_evaluator1, evaluated: team)
    FactoryGirl.create(:evaluating, evaluator: team_evaluator2, evaluated: team)
    FactoryGirl.create(:evaluating, evaluator: team_evaluator3, evaluated: team)
    submission1 = FactoryGirl.create(:submission, team: team, milestone: milestone1)
    submission2 = FactoryGirl.create(:submission, team: team, milestone: milestone2)
    FactoryGirl.create(:peer_evaluation, team: team_evaluator1,
                       submission: submission1, private_content: '{"q[5][1]":"2"}')
    FactoryGirl.create(:peer_evaluation, team: team_evaluator2,
                       submission: submission1, private_content: '{"q[5][1]":"3"}')
    FactoryGirl.create(:peer_evaluation, team: team_evaluator3,
                       submission: submission1, private_content: '{"q[5][1]":"2"}')
    FactoryGirl.create(:peer_evaluation, team: team_evaluator1,
                       submission: submission2, private_content: '{"q[6][1]":"2"}')
    FactoryGirl.create(:peer_evaluation, team: team_evaluator2,
                       submission: submission2, private_content: '{"q[6][1]":"3"}')
    average_ratings_hash = team.get_average_evaluation_ratings
    expect(average_ratings_hash.length).to eql 4
    expect(average_ratings_hash[milestone1.id]).to be_within(0.05).of(2.33)
    expect(average_ratings_hash[milestone2.id]).to be_within(0.05).of(2.5)
    expect(average_ratings_hash[milestone3.id]).to be_nil
    expect(average_ratings_hash[:all]).to be_within(0.05).of(2.4)
    FactoryGirl.create(:peer_evaluation, adviser: adviser, owner_type: 1,
                       submission: submission2, private_content: '{"q[6][1]":"3"}')
    average_ratings_hash = team.get_average_evaluation_ratings
    expect(average_ratings_hash.length).to eql 4
    expect(average_ratings_hash[milestone1.id]).to be_within(0.05).of(2.33)
    expect(average_ratings_hash[milestone2.id]).to be_within(0.05).of(2.75)
    expect(average_ratings_hash[milestone3.id]).to be_nil
    expect(average_ratings_hash[:all]).to be_within(0.05).of(2.58)
  end

  it '#get_average_feedback_ratings' do
    user_adviser = FactoryGirl.create(:user, email: 'user1@team.model.spec', uid: 'uid6@team.model.spec')
    adviser = FactoryGirl.create(:adviser, user: user_adviser)
    team = FactoryGirl.create(:team, team_name: '1.team.model.spec', adviser: adviser)
    team_evaluated1 = FactoryGirl.create(:team, team_name: '2.team.model.spec')
    team_evaluated2 = FactoryGirl.create(:team, team_name: '3.team.model.spec')
    team_evaluated3 = FactoryGirl.create(:team, team_name: '4.team.model.spec')
    FactoryGirl.create(:evaluating, evaluated: team_evaluated1, evaluator: team)
    FactoryGirl.create(:evaluating, evaluated: team_evaluated2, evaluator: team)
    FactoryGirl.create(:evaluating, evaluated: team_evaluated3, evaluator: team)
    survey_template1 = FactoryGirl.create(:survey_template, survey_type: 2)
    FactoryGirl.create(:feedback, team: team_evaluated1, target_team: team,
                       survey_template: survey_template1, response_content: '{"1": "0"}')
    FactoryGirl.create(:feedback, team: team_evaluated2, target_team: team,
                       survey_template: survey_template1, response_content: '{"1": "2"}')
    FactoryGirl.create(:feedback, team: team_evaluated3, target_team: team,
                       survey_template: survey_template1, response_content: '{"1": "2"}')
    feedback_ratings_hash = team.get_average_feedback_ratings
    expect(feedback_ratings_hash[:all]).to be_within(0.05).of(1.33)
  end
end
