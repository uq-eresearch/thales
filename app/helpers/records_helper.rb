module RecordsHelper

  # Generates HTML for displaying a field and its value(s)
  # on the show record page.
  #
  # The values can either be a string or an array. If it is nil, nothing
  # is generated.

  def show_field(values, label)

    if ! values.nil?

      if ! (values.respond_to?(:each) && values.respond_to?(:size))
        values = [ values ]
      end

      if 0 < values.size
        content_tag(:div, { :class => 'item' }) do
          content_tag(:dl) do
            c = ''
            first = true
            values.each do |val|

              c += content_tag(:dt) do
                label
              end

              if first
                dd_attrs = { :class => 'first' }
              end
              c += content_tag(:dd, dd_attrs) do
                val
              end

              first = false
            end
            raw c
          end # :dl
        end # :div

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
          options = maxlength.nil? ? {} : { :maxlength => maxlength }
          text_field_tag(name, default_value, options)
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
      options = maxlength.nil? ? {} : { :maxlength => maxlength }
      text_field_tag(name, value, options)
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
          options = maxlength.nil? ? {} : { :maxlength => maxlength }
          # TODO: might need to add :class to options
          text_area_tag(name, default_value, options)
        end
      end
    end
  end

end
