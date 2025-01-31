# coding: utf-8  
class Node
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :summary
  field :sort, :type => Integer, :default => 0
  field :topics_count, :type => Integer, :default => 0
  
  has_many :topics
  belongs_to :section
  
  validates_presence_of :name, :summary
  validates_uniqueness_of :name
  
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following_nodes

  scope :hots, desc(:topics_count)

   # 存放用户最近访问节点
  def self.set_user_last_visited(user_id,node_id)
    last_visites = get_user_last_visites(user_id)
    last_visites.delete(node_id)

    if(last_visites.length == 10)
      last_visites.pop
    end
    last_visites.insert(0,node_id)
    Rails.cache.write("Node:get_user_last_visites:#{user_id}",last_visites)
  end

  # 取得用户最近访问的节点
  # TODO: 这里有 Bug, 一个节点能取出，两个以上就不行了，自从 mongoid 加入后出现的问题
  def self.get_user_last_visites(user_id)
    last_visites = Rails.cache.read("Node:get_user_last_visites:#{user_id}")
    if last_visites.blank?
      last_visites = []
      Rails.cache.write("Node:get_user_last_visites:#{user_id}", last_visites)
    end
    return last_visites.dup
  end

  def self.find_last_visited_by_user(user_id,limit = 10)
    ids = get_user_last_visites(user_id)
    if ids.blank?
      return []
    else
      limit(limit).all_in(:_id => ids)
    end
  end
end
