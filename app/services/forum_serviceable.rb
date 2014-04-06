class ForumServiceable
  include ExtjsRails
  include TwitterModule
  include TinyUrlHelper
  include ActionView::Helpers::TextHelper


  def initialize(params, session)
    @params = params
    @session = session
    @forum_threshold = -6
    @per_page=12
  end


  def create_recent
    board = ForumBoard.new
    board[:board_id] = 0
    board[:title] = 'Recent'
    board[:status] = 2
    board
  end


  # format Twitter post
  def format_twitter_post(post)
    url = 'http://jazzhouston.com/forums/messages/' + post.thread_id.to_s
    link = tinyurl(url)
    # catch Error
    if link == 'Error'
      link = url
    end
    str = 'New Forum Post: ' + post.title.to_s + ' by ' + post.user.username + ' ' + link  + ' #jazzhouston'
    truncate(str, :length => 140)
  end

  def vote(user_id, message_id, vote_up)
    incr_value= vote_up? ? 1: -1
    # check for existing vote
    message = MessageScore.vote(current_user.user_id, message_id, incr_value)
    data={}
    if message.nil?
      data['alert']='you\'ve already voted on this message!'
      data['success']=0
    else
      data['success']=1
      data['score'] = message.rating
      data['author'] = message.user.username
      data['hide'] = (message.rating <= @forum_threshold)
      data['reopen'] = (message.rating - incr_value <= @forum_threshold)
    end
    data
  end



end