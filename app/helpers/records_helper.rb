require 'thales/datamodel/e_research'

module RecordsHelper

  # Generates HTML for displaying a field and its value(s)
  # on the show record page.
  #
  # The values can either be a string or an array. If it is nil, nothing
  # is generated.

  def show_all(data, include_non_profile = false)
    profile = data.class.profile
    result = ''

    # Show properties known to the profile

    profile.all_groups do |heading, global_ids|

      if (! global_ids.index { |gid| data.property_populated?(gid) }.nil?)
        # Group has contents, so append the title and contents
        result += content_tag(:h3) { heading }
        global_ids.each do |gid|
          f = show_field(data, gid)
          if ! f.nil?
            result += f
          end
        end
      end

    end

    if include_non_profile
      # Show properties not known to the profile

      outputted_header = false
      data.property_all do |global_id, values|
        if ! profile.symbol_table.has_key?(global_id)
          if ! outputted_header
            result += content_tag(:h3) { 'Properties not in profile' }
            outputted_header = true
          end
          result += show_field(data, global_id)
        end
      end
    end

    return raw result
  end

  def show_field(data, gid)

    if ! data.property_populated?(gid)
      return nil
    end

    label = nil
    profile_entry = data.class.profile[gid]
    if profile_entry
      text = profile_entry[:label]
      if text && ! text.blank?
        label = content_tag(:span) { text }
      end
    end
    if label.nil?
      pos = gid.rindex('/')
      if ! pos.nil? && pos != gid.size - 1
        str = "Unknown property (...#{ gid.slice(pos, gid.size - pos) })"
      else
        str = "Unknown property"
      end
      label = content_tag(:span, :title => gid.to_s) { str }
    end

    content_tag(:div, { :class => 'item' }) do
      content_tag(:dl) do
        c = ''
        first = true

        data.property_get(gid).each do |val|

          c += content_tag(:dt) { label }

          c += content_tag(:dd, first ? { :class => 'first' } : nil) {
            if ! val.respond_to? :uri
              # Text property
              val
            else
              # Link property
              uri = val.uri
              display_text = val.hint
              if display_text.nil? || display_text.blank?
                display_text = uri
              end
              if uri.starts_with?('https://', 'http://', 'mailto:')
                # Display link as a hyperlink
                content_tag(:a, :href => uri,
                            :class => 'link') { display_text }
              else
                # Display link as non-hyperlinked text
                content_tag(:span, :title => val.uri,
                            :class => 'link') { display_text }
              end
            end
          }

          first = false
        end
        raw c
      end # :dl
    end # :div
  end

  def form_all(data)
    profile = data.class.profile

    result = ''

    profile.all_groups do |title, global_ids|
      result += content_tag(:h3) { title }
      global_ids.each do |gid|
        result += field_prop(data, 
                             data.class.profile[gid],
                             profile.symbol_table[gid])
      end
    end
    return raw result
  end

  def field_prop(data, info, symbol)
    values = data.send(symbol)
    name_base = symbol.to_s

    name = 'collection' + '[' + name_base + ']'

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
            text_field_tag(name, value_str, attr)
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

    name = 'collection' + '[' + name_base + ']'

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

  def field_text_0n(name_base, label_text, values = nil, maxlength = nil)

    # <div class="item" id="name_base">
    #   <dl>
    #     <dt><label>...</label></dt>
    #     <dd class="first"><input/></dd>
    #     <dt><label>...</label></dt>
    #     <dd><input/></dd>
    #     ...
    #   </dl>
    #   <p><a class="addField">+</a></p>
    # </div>

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
    name = 'collection' + '[' + name_base + ']' + '[' + count.to_s + ']'

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

    name = 'collection' + '[' + name_base + ']'

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

end
