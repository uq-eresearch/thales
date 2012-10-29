module ApplicationHelper

  class SideNavBar

    def self.generate
    end

  end

  # Generates HTML for the login/logout block.

  def login_block

    content_tag :div, :id => 'login-block' do

      if logged_in?
        # Block with username and logout
        [
         content_tag(:p, current_user.auth_name, :class => 'username'),
         content_tag(:p, :class => 'login-link logout') do
           link_to('Sign out', logout_path)
         end
        ].reduce :+

      else
        # Block with login
        content_tag :p, :class => 'login-link login' do
          link_to('Sign in', login_path)
        end # p
      end

    end # div
  end

  # Generates HTML for record searching

  def search_block
    content_tag :div, :id => 'search' do
      form_tag records_path('.', { :id => 'search' }) do
        [
         label_tag(:q, 'Search'),
         search_field_tag('q', nil),
         submit_tag('Search')
        ].reduce :+
      end # form
    end # div
  end

end
