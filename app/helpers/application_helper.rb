# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

# Ruby on Rails helper.

module ApplicationHelper

  # HTML for the side navigation bar.
  #
  # Generates HTML that looks like this
  #   <ul id="navigation">
  #    <li><a class="head" href="#">Records</a>
  #      <ul class="section">
  #        <li><a href="<%= records_path %>">Search</a></li>
  #        <li><a href="<%= records_path %>">Browse</a></li>
  #        <li><a href="<%= new_record_path type: 'collection'  %>">Create a new collection record</a></li>
  #        <li><a href="<%= new_record_path type: 'party' %>">Create a new party record</a></li>
  #        <li><a href="<%= new_record_path type: 'activity' %>">Create a new activity record</a></li>
  #        <li><a href="<%= new_record_path type: 'service' %>">Create a new service record</a></li>
  #      </ul>
  #    </li>
  #    <li><a class="head" href="/">Settings</a></li>
  #    <li><a class="head" href="<%= users_path %>">Administration</a></li>
  #    <li><a class="head link" href="/help">Help</a></li>
  #   </ul>
  #
  # ==== Parameters
  #
  # +expand+:: symbol indicating which section to expand.
  #            Should be either <tt>:records</tt> or <tt>:administration</tt>.

  def side_nav_bar(expand)
    content_tag(:ul, id: 'navigation') do
      [
       side_nav_records(expand == :records),
       # content_tag(:li) { link_to('Settings', '/', class: 'head') },
       side_nav_administration(expand == :administration),
       content_tag(:li) { link_to('Help', '/help', class: 'head link') },
      ].reduce :+
    end # </ul>
  end

  private
  def side_nav_records(expanded)
    content_tag(:li) do
      [
       link_to('Records', records_path, class: 'head'),
       if expanded
         content_tag(:ul, class: 'section') do
           [
            content_tag(:li) { link_to('Browse', records_path) },
            content_tag(:li) { link_to('Create collection',
                                       new_record_path(type: 'collection')) },
            content_tag(:li) { link_to('Create party',
                                       new_record_path(type: 'party')) },
            content_tag(:li) { link_to('Create activity',
                                       new_record_path(type: 'activity')) },
            content_tag(:li) { link_to('Create service',
                                       new_record_path(type: 'service')) },
           ].reduce :+
         end # </ul>
       else
         ''
       end
      ].reduce :+
    end
  end

  private
  def side_nav_administration(expanded)
    # Administration secton
    content_tag(:li) do
      [
       link_to('Administration', users_path, class: 'head'),
       if expanded
         content_tag(:ul, class: 'section') do
           [
            content_tag(:li) { link_to('Users', users_path) },
            content_tag(:li) { link_to('Roles', roles_path) },
            content_tag(:li) { link_to('Settings', settings_path) },
           ].reduce :+
         end # </ul>
       else
         ''
       end
      ].reduce :+
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
    content_tag :div, :id => 'record-search' do
      form_tag records_path, { :method => 'get', :id => 'search' } do
        [
         label_tag(:q, 'Search'),
         search_field_tag('q', nil, :placeholder => 'Search for records'),
         submit_tag('Search', :id => 'submit')
        ].reduce :+
      end # form
    end # div
  end

end
