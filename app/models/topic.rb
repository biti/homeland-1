# coding: utf-8  
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::SoftDelete
  include Redis::Search
  include Redis::Objects
  
  field :title
  field :body    
  field :replied_at , :type => DateTime
  field :source
  field :message_id  
  field :replies_count, :type => Integer, :default => 0
  
  belongs_to :user, :inverse_of => :topics
  belongs_to :node
  belongs_to :last_reply_user, :class_name => 'User'
  has_many :replies
  
  attr_protected :user_id
  validates_presence_of :user_id, :title, :body, :node_id
  
  counter :hits, :default => 0
  
  redis_search_index(:title_field => :title,
                     :score_field => :replied_at,
                     :ext_fields => [:node_name,:replies_count])

  # scopes
  scope :last_actived, desc("replied_at").desc("created_at")
  scope :recents, desc("id")

  before_save :set_replied_at
  def set_replied_at
    self.replied_at = Time.now
  end
  
  def node_name
    return "" if self.node.blank?
    self.node.name
  end
  
  # 检查用户是否看过
  # result:
  #   0 读过
  #   1 未读
  #   2 最后是用户的回复
  def user_readed?(user_id)
    uids = Rails.cache.read("Topic:user_read:#{self.id}")
    if uids.blank?
      if self.last_reply_user_id == user_id || self.user_id == user_id
        return 2
      else 
        return 1
      end
    end

    if uids.index(user_id)
      return 0
    else
      if self.last_reply_user_id == user_id || self.user_id == user_id
        return 2
      else 
        return 1
      end
    end
  end

  # 记录用户读过
  def user_readed(user_id)
    uids = Rails.cache.read("Topic:user_read:#{self.id}")
    if uids.blank?
      uids = [user_id]
    else
      uids = uids.dup
    end

		uids << user_id
    Rails.cache.write("Topic:user_read:#{self.id}",uids)
  end

  # 清除用户读过的记录
  # 用户回复的时候清除状态
  def clear_user_readed
    Rails.cache.write("Topic:user_read:#{self.id}",nil)
  end
  
  def self.search(key,options = {})
    paginate :conditions => "title like '%#{key}%'",:page => 1
  end
  
  def self.cached_count
    return Rails.cache.fetch("topics/count",:expires_in => 1.hours) do
      self.count
    end
  end
  
  def self.find_by_message_id(message_id)
    where(:message_id => message_id).first
  end
end
