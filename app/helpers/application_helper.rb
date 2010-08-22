module ApplicationHelper

  # Return a title on a per-page basis
  def title
    base_title = 'Ruby on Rails Tutorial Sample App'
    @title.nil?? base_title : "#{base_title} | #{@title}"
  end
end
