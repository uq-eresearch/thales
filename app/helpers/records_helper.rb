# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require_relative '../models/record'

require 'thales/datamodel'

# Ruby on Rails helper.

module RecordsHelper

  # Generates HTML to show all properties. This is useful for
  # debugging.
  #
  # ==== Parameters
  #
  # +data+:: an instance of a Thales::Datamodel::Cornerstone::Record
  #
  # ==== Returns
  #
  # HTML

  def show_all(data)
    result = content_tag(:h3) { 'All properties' }

    g_profile = {}
    data.class.profile.each do |symbol, prop_info|
      g_profile[prop_info[:gid]] = prop_info
    end

    data.property_all do |gid, values|
      result += show_property(symbol, values, g_profile[gid], gid)
    end

    return raw result
  end

  # Generates HTML for displaying a field and its value(s)
  # on the show record page.
  #
  # The values can either be a string or an array. If it is nil, nothing
  # is generated.
  #
  # ==== Parameters
  #
  # +data+:: an instance of a Thales::Datamodel::Cornerstone::Record
  # +heading+:: text to display in +h3+ tag
  # +symbols+:: zero or more symbols
  #
  # ==== Returns
  #
  # HTML to show the +heading+ followed by values from +data+
  # corresponding to the supplied +symbols+. Only +symbols+ which have
  # values are included.
  #
  # If none of the +symbols+ have values, the empty string is
  # returned. That is, the +heading+ is only shown if there are
  # values.

  def show_group(data, heading, *symbols)
    result = ''

    symbols.each do |symbol|
      values = data.send(symbol)

      if ! values.empty?
        if heading
          result += content_tag(:h3) { heading }
          heading = nil
        end
        result += show_property(symbol, values, data.class.profile[symbol])
      end

    end

    return raw result
  end

  # Generates HTML to show all the values of a single property.
  #
  # ==== Parameters
  #
  # +symbol+:: property symbol
  # +values+:: array of values
  # +prop_info+:: optional profile item defining the property.
  # +gid+:: global identifier for the property.
  #
  # ==== Returns
  #
  # HTML

  def show_property(symbol, values, prop_info = nil, gid = nil)

# TODO: what did this do?    if ! data.property_populated?(gid)
#      return nil
#    end

    text = prop_info ? prop_info[:label] : nil
    if text && ! text.blank?
      # Non-blank label exists, use it
      label = content_tag(:span) { text }
    else
      # Derive a label from the gid
      gid = prop_info ? prop_info[:gid] : (gid ? gid : '?')
      pos = gid.rindex('/')
      if ! pos.nil? && pos != gid.size - 1
        str = "? (#{ gid.slice(pos + 1, gid.size - pos - 1) })"
      else
        str = "?"
      end
      label = content_tag(:span, :title => gid.to_s) { str }
    end

    content_tag(:div, { :class => 'item' }) do
      content_tag(:dl) do
        c = ''
        first = true

        values.each do |val|

          c += content_tag(:dt) { label }

          c += content_tag(:dd, first ? { :class => 'first' } : nil) {
            SHOW_METHODS[symbol].call(val, self)
            #self.content_tag(:strong, "aaa")
          }

          first = false
        end
        raw c
      end # :dl
    end # :div
  end

  SHOW_METHODS = {}

  SHOW_METHODS[:identifier] =
    ->(value, result) {
    result.content_tag(:span, style: 'font-size: small;') { value }
  }

  SHOW_METHODS[:tag_FoR] =
    ->(val, result) {
    uri = val.uri
    display_text = val.hint
    if display_text.nil? || display_text.blank?
      display_text = uri
      if uri.start_with?(Thales::Datamodel::EResearch::Base::FOR_URI_PREFIX)
        rest = uri[Thales::Datamodel::EResearch::Base::FOR_URI_PREFIX.length..-1]
        if rest =~ /^(\d+)$/
          display_text = "<#{$~[1]}>"
        end
      end
    end
    result.content_tag(:span, :title => "FoR code: #{uri}") { display_text }
  }

  SHOW_METHODS[:tag_SEO] =
    ->(val, result) {
    uri = val.uri
    display_text = val.hint
    if display_text.nil? || display_text.blank?
      display_text = uri
      if uri.start_with?(Thales::Datamodel::EResearch::Base::SEO_URI_PREFIX)
        rest = uri[Thales::Datamodel::EResearch::Base::SEO_URI_PREFIX.length..-1]
        if rest =~ /^(\d+)$/
          display_text = "<#{$~[1]}>"
        end
      end
    end
    result.content_tag(:span, :title => "SEO code: #{uri}") { display_text }
  }

  SHOW_METHODS[:contact_email] =
    ->(value, result) {
    result.content_tag(:a, :href => "mailto:#{value}") { value }
  }

  SHOW_METHODS[:web_page] =
    ->(value, result) {
    result.content_tag(:a, :href => value) { value }
  }

  SHOW_METHODS.default =
    ->(val, result) {

    if ! val.respond_to?(:uri)
      # Text property
      return val
    end

    # Link property

    uri = val.uri
    display_text = val.hint
    if display_text.nil? || display_text.blank?
      display_text = uri
    end

    matches = Record.find_by_identifier(val.uri)
    if matches && ! matches.empty?
      # The system has record(s) with this identifier, so link to them.
      # In normal practice there would be only record, but it is possible
      # for more than one record to contain the same identifier.
      m = ''
      matches.each do |record|
        r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
        data = r_class.new.deserialize(record.ser_data)

        m += '<br/>' if m != ''
        m += result.link_to(data.display_title, record,
                            class: 'link-internal',
                            title: "Internal record: #{display_text}")
      end
      result.raw m

    else
      # No record exist in the system with this identifier, so display it
      # as an external hyperlink or as text.
      if uri.starts_with?('https://', 'http://', 'mailto:')
        # Display link as a hyperlink
        result.content_tag(:a, :href => uri,
                    class: 'link-external', title: 'External identifier') { display_text }
      else
        # Display link as non-hyperlinked text
        result.content_tag(:span, :title => val.uri,
                    :class => 'link-identifier') { display_text }
      end
    end
  }

  # Generates HTML for displaying the subtype of a record.
  #
  # ==== Parameters
  #
  # +data+:: an instance of a Thales::Datamodel::Cornerstone::Record
  #
  # ==== Returns
  #
  # HTML

  def show_subtype(data)
    result = ''
    sts = data.subtype
    if sts
      sts.each do |st|
        result += show_property(:subtype,
                                [ st[/[^\/]*\/[^\/]*$/] ],
                                { label: 'Type/subtype' })
      end
    end
    return raw result
  end

  # Generates HTML for editing the subtype.

  def form_subtype(data)
    name = :data_subtype

    if @data.instance_of? Thales::Datamodel::EResearch::Collection
      label = 'Collection subtype'
      options = [
                 ['Collection', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/collection/collection"],
                 ['Dataset', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/collection/dataset"],
                ]
    elsif @data.instance_of? Thales::Datamodel::EResearch::Party
      label = 'Party subtype'
      options = [
                 ['Person', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/party/person"],
                 ['Group', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/party/group"],
                 ['Administrative position', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/party/position"],
                ]
    elsif @data.instance_of? Thales::Datamodel::EResearch::Activity
      label = 'Activity subtype'
      options = [
                 ['Project', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/activity/project"],
                 ['Program', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/activity/program"],
                ]
    elsif @data.instance_of? Thales::Datamodel::EResearch::Service
      label = 'Service subtype'
      options = [
                 ['Report', "#{Thales::Datamodel::EResearch::Base::SUBTYPE_BASE_URI}/service/report"],
                ]
    else
      raise 'internal error: not implemented yet'
    end
    
    content_tag(:div, { :class => 'item' }) do
      content_tag(:dl) do
        c = content_tag(:dt) do
          label_tag(name, label)
        end
        c += content_tag(:dd, { :class => 'first' }) do
          select_tag(:data_subtype,
                     options_for_select(options, data.subtype[0]),
                     name: 'data[subtype]')
        end # :dd
      end # :dl
    end # :div

  end

  # Generates HTML for editing the values of a field.
  #
  # ==== Parameters
  #
  # +data+:: an instance of a Thales::Datamodel::Cornerstone::Record
  # +heading+:: text to display in +h3+ tag
  # +symbols+:: zero or more symbols
  #
  # ==== Returns
  #
  # HTML showing the +heading+ followed by edit fields from +data+
  # corresponding to the supplied +symbols+.

  def form_group(data, heading, *symbols)
    result = content_tag(:h3) { heading }

    symbols.each do |symbol|
      result += field_prop(symbol, data.class.profile[symbol],
                           data.send(symbol))
    end

    return raw result
  end

  def field_prop(symbol, info, values)

    name_base = symbol.to_s

    name = 'data' + '[' + name_base + ']'

    maxlength = info[:maxlength]

    default_label = info[:label]
    label = (! default_label.nil?) ? default_label : symbol.to_s

    if info[:singular]
      # Fields for a non-repeating property

      if ! info[:is_link]
        # Text property
        value_str = values[0]
      else
        # Link property
        if values[0].nil?
          value_str = ''
        else
          value_str = "#{values[0].uri} -- #{values[0].hint}"
        end
      end

      content_tag(:div, { :class => 'item' }) do
        content_tag(:dl) do
          c = content_tag(:dt) do
            label_tag(name, label)
          end
          c += content_tag(:dd, { :class => 'first' }) do
            attr = maxlength.nil? ? {} : { :maxlength => maxlength }
            if info[:textarea]
              text_area_tag(name, value_str, attr)
            else
              text_field_tag(name, value_str, attr)
            end
          end
        end # :dl
      end # :div

    else
      # Fields for a repeatable property

      content_tag(:div, { :class => 'item', :id => name_base }) do
        html = ''
        html += content_tag(:dl) do
          s = ''
          count = 0

          # Fields to hold existing values

          values.each do |val|
            if ! info[:is_link]
              # Text property
              value_str = val
            else
              # Link property
              value_str = "#{val.uri} #{val.hint}"
            end

            s += field_text_0n_internal(count, name_base,
                                        label, value_str, maxlength)
            count += 1
          end
          
          # An extra blank one to enter in a new value

          s += field_text_0n_internal(count, name_base,
                                      label,
                                      nil, maxlength)
          raw s
        end # dl
        
        # Add button

        html += content_tag(:p, { :class => 'addField' }) do
          raw "<a title=\"Add #{label}\"" +
            " class=\"addField\"" +
            " onclick=\"thales.replicateField(&quot;#{name_base}&quot;);\"" +
            ">&#x271A;</a>"
        end

        raw html
      end
    end

  end

  # Generate a HTML form field for editing a single value.

  def field_text_1(name_base, label_text, default_value = nil, maxlength = nil)

    name = 'data' + '[' + name_base + ']'

    content_tag(:div, { :class => 'item' }) do
      content_tag(:dl) do
        c = content_tag(:dt) do
          label_tag(name, label_text)
        end
        c += content_tag(:dd, { :class => 'first' }) do
          attr = maxlength.nil? ? {} : { :maxlength => maxlength }
          text_field_tag(name, default_value, attr)
        end
      end # :dl
    end # :div
  end

  # Generate HTML form fields for editing optional and repeatable values.
  #
  # ==== Parameters
  #
  # +name_base+::
  # +label_text+::
  # +values+:: optionan
  # +maxlength+:: optional
  #
  # ==== Returns
  #
  # HTML that follows this structure:
  #
  #   <div class="item" id="name_base">
  #     <dl>
  #       <dt><label>...</label></dt>
  #       <dd class="first"><input/></dd>
  #       <dt><label>...</label></dt>
  #       <dd><input/></dd>
  #       ...
  #     </dl>
  #     <p><a class="addField">+</a></p>
  #   </div>
  #
  # HTML
  
  def field_text_0n(name_base, label_text, values = nil, maxlength = nil)

    content_tag(:div, { :class => 'item', :id => name_base }) do

      html = ''

      html += content_tag(:dl) do

        s = ''
        count = 0

        # Fields to hold existing values

        values.each do |value|
          s += field_text_0n_internal(count, name_base, label_text,
                                      value, maxlength)
          count += 1
        end
        
        # An extra blank one to enter in a new value

        s += field_text_0n_internal(count, name_base, label_text,
                                    nil, maxlength)
        raw s
      end # dl
      
      # Add button

      html += content_tag(:p, { :class => 'addField' }) do
        raw "<a title=\"Add #{label_text}\"" +
          " class=\"addField\"" +
          " onclick=\"thales.replicateField(&quot;#{name_base}&quot;);\"" +
          ">&#x271A;</a>"
      end

      raw html
    end
  end

  private
  def field_text_0n_internal(count, name_base, label_text,
                             value, maxlength)
    name = 'data' + '[' + name_base + ']' + '[' + count.to_s + ']'

    html = content_tag(:dt) do
      label_tag(name, label_text)
    end

    if count == 0
      dd_attrs = { :class => 'first' }
    end
    html += content_tag(:dd, dd_attrs) do
      attr = maxlength.nil? ? {} : { :maxlength => maxlength }
      text_field_tag(name, value, attr)
    end

    html
  end

  def field_area_1(name_base, label_text, default_value = nil, maxlength = nil)

    name = 'data' + '[' + name_base + ']'

    content_tag(:div, { :class => 'item' }) do
      content_tag(:dl, { :class => 'item' }) do
        c = content_tag(:dt) do
          label_tag(name, label_text)
        end

        c += content_tag(:dd, { :class => 'first' }) do
          attr = maxlength.nil? ? {} : { :maxlength => maxlength }
          # TODO: might need to add :class to attr
          text_area_tag(name, default_value, attr)
        end
      end
    end
  end

  def form_oaipmh_status(record)

    content_tag(:div, { class: 'item' }) do
      content_tag(:dl) do
        c = content_tag(:dt) { 'Status' }
        c += content_tag(:dd, { class: 'first' }) do

          options = []
          if record.oaipmh_record.nil?
            options << [ 'Not in feed (current status)', 0 ]
            options << [ 'Publish', 1 ]
          elsif record.oaipmh_record.deleted?
            options << [ 'Deleted record in the feed (current status)', -1 ]
            options << [ 'Publish', 1 ]
          else
            options << [ 'Published record in the feed (current status)', 1 ]
            options << [ 'Deleted record in the feed', -1 ]
          end
          select_tag(:oaipmh_status, options_for_select(options))
        end
      end
    end
  end

end

#EOF
