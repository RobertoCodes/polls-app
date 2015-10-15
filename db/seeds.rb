# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
Poll.destroy_all
Question.destroy_all
AnswerChoice.destroy_all
Response.destroy_all

u1 = User.create!(user_name: 'Samson')
u2 = User.create!(user_name: 'Ryan')
u3 = User.create!(user_name: 'The Baron Carl')
u4 = User.create!(user_name: "Jon 'white-sneakers' T")

poll1 = Poll.create!(title: 'Which poll is best?', author_id: u1.id)

q1 = Question.create!(text: 'What kind of polls do you like?', poll_id: poll1.id)
q2 = Question.create!(text: 'What kind of polls do you hate?', poll_id: poll1.id)


a1 = AnswerChoice.create!(choice: 'sexy polls', question_id: q1.id )
a2 = AnswerChoice.create!(choice: 'stripper polls', question_id: q1.id )

a3 = AnswerChoice.create!(choice: 'shitty polls', question_id: q2.id )
a4 = AnswerChoice.create!(choice: 'sarcastic polls', question_id: q2.id )

a1.responses.create!(user_id: u2.id)
a3.responses.create!(user_id: u2.id)
a1.responses.create!(user_id: u3.id)
