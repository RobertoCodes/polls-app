# == Schema Information
#
# Table name: responses
#
#  id               :integer          not null, primary key
#  answer_choice_id :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Response < ActiveRecord::Base
  validates :answer_choice_id, presence: :true
  validates :user_id, presence: :true
  validate :respondent_has_not_already_answered_question
  validate :cant_respond_to_own_poll

  belongs_to :answer_choice,
    class_name: 'AnswerChoice',
    foreign_key: :answer_choice_id,
    primary_key: :id

  belongs_to :respondent,
    class_name: 'User',
    foreign_key: :user_id,
    primary_key: :id

    def question
      answer_choice.question
    end

    def poll
      answer_choice.question.poll
    end

    def sibling_responses
      if self.id.nil?
        Response.find_by_sql("
        SELECT
          responses.*
        FROM
          questions
        JOIN
          answer_choices AS ac
        ON
          ac.question_id = questions.id AND ac.id = #{answer_choice_id}
        JOIN
          answer_choices AS ac2
        ON
          ac2.question_id = questions.id
        JOIN
          responses
        ON
          responses.answer_choice_id = ac2.id
        ")
      else
        Response.find_by_sql("
        SELECT
          responses.*
        FROM
          questions
        JOIN
          answer_choices AS ac
        ON
          ac.question_id = questions.id AND ac.id = #{answer_choice_id}
        JOIN
          answer_choices AS ac2
        ON
          ac2.question_id = questions.id
        JOIN
          responses
        ON
          responses.answer_choice_id = ac2.id AND responses.user_id != #{id}"
        )
      end
    end

    private
      def respondent_has_not_already_answered_question
        sibling_responses.each do |response|
          if response.user_id == self.user_id
            errors[:already_answered] << "This user has already answered the question"
          end
        end
      end

    def cant_respond_to_own_poll
      author_id = Poll.find_by_sql("
        SELECT
          polls.*
        FROM
          polls
        JOIN
          questions
        ON
          questions.poll_id = polls.id
        JOIN
          answer_choices
        ON
          answer_choices.question_id = questions.id
        WHERE
          answer_choices.id = #{answer_choice_id}
        ").first.author_id
      if author_id == self.user_id
        errors[:author_cannot_answer] << "Author can't respond to own poll"
      end
    end

end
