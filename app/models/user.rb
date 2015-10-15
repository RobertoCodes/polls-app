# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  validates :user_name, presence: :true

  has_many :polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id

  has_many :responses,
    class_name: "Response",
    foreign_key: :user_id,
    primary_key: :id

  def completed_polls
    Poll.select("polls.*, COUNT(DISTINCT questions.*) AS num_questions, COUNT(user_responses.*) AS num_responses")
        .joins(questions: :answer_choices)
        .joins(<<-SQL)
          LEFT OUTER JOIN (
            SELECT
              *
            FROM
              responses
            WHERE
              responses.user_id = #{id}
          ) AS user_responses
          ON
            user_responses.answer_choice_id = answer_choices.id
        SQL
        .group("polls.id")
        .having("COUNT(DISTINCT questions.*) = COUNT(user_responses.*)")
  end

  def in_progress_polls
    Poll.select("polls.*, COUNT(DISTINCT questions.*) AS num_questions, COUNT(user_responses.*) AS num_responses")
        .joins(questions: :answer_choices)
        .joins(<<-SQL)
          LEFT OUTER JOIN (
            SELECT
              *
            FROM
              responses
            WHERE
              responses.user_id = #{id}
          ) AS user_responses
          ON
            user_responses.answer_choice_id = answer_choices.id
        SQL
        .group("polls.id")
        .having("COUNT(user_responses.*) BETWEEN 1 AND (COUNT(DISTINCT questions.*) - 1) ")
  end

  # def completed_polls
  #   Poll.find_by_sql(["
  #   SELECT
  #     polls.*, COUNT(DISTINCT questions.*) AS num_questions, COUNT(user_responses.*) AS num_responses
  #   FROM
  #     polls
  #   JOIN
  #     questions
  #   ON
  #     questions.poll_id = polls.id
  #   JOIN
  #     answer_choices
  #   ON
  #     answer_choices.question_id = questions.id
  #   LEFT OUTER JOIN
  #     ( SELECT
  #         *
  #       FROM
  #         responses
  #       WHERE
  #         responses.user_id = ? d
  #         ) AS user_responses
  #   ON
  #     user_responses.answer_choice_id = answer_choices.id
  #   GROUP BY
  #     polls.id
  #   HAVING
  #     COUNT(DISTINCT questions.*) = COUNT(user_responses.*)
  #     ", self.id] )
  # end

end
