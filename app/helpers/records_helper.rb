module RecordsHelper

  def show_field(values, label)

    if ! values.nil?
      if ! (values.respond_to?(:each) && values.respond_to?(:size))
        values = [ values ]
      end

      if 0 < values.size
        content_tag(:div, { :class => 'item' }) do
          c = ''
          first = true
          values.each do |val|
            if first
              label_class = 'label'
              field_class = 'field'
            else
              label_class = 'labelextra'
              field_class = 'fieldextra'
            end

            c += content_tag(:p, { :class => label_class }) do
              label
            end
            c += content_tag(:p, { :class => field_class }) do
              val
            end

            first = false
          end
          raw c
        end
      end
    end
  end

  def field_text_1(name, label_text, default_value = nil, maxlength = nil)

    content_tag(:div, { :class => 'item' }) do
      c = content_tag(:p, { :class => 'label' }) do
        label_tag(name, label_text)
      end
      c += content_tag(:p, { :class => 'field' }) do
        options = maxlength.nil? ? {} : { :maxlength => maxlength }
        text_field_tag(name, default_value, options)
      end

    end
  end

  def field_text_0n(name_base, label_text, values = nil, maxlength = nil)

    content_tag(:div, { :class => 'item' }) do

      contents = ''
      count = 0

      values.each do |value|
        contents += field_text_0n_internal(count, name_base, label_text,
                                           value, maxlength)
        count += 1
      end
      contents += field_text_0n_internal(count, name_base, label_text,
                                         nil, maxlength)
      raw contents
    end
  end

  private
  def field_text_0n_internal(count, name_base, label_text,
                             value, maxlength)
    if count == 0
      label_class = 'label'
      field_class = 'field'
    else
      label_class = 'labelextra'
      field_class = 'fieldextra'
    end

    name = name_base.to_s + '[' + count.to_s + ']'

    c = content_tag(:p, { :class => label_class }) do
      label_tag(name, label_text)
    end

    c += content_tag(:p, { :class => field_class }) do
      options = maxlength.nil? ? {} : { :maxlength => maxlength }
      text_field_tag(name, value, options)
    end
    
  end

  def field_area_1(name, label_text, default_value = nil, maxlength = nil)

    content_tag(:div, { :class => 'item' }) do
      c = content_tag(:p, { :class => 'label' }) do
        label_tag(name, label_text)
      end
      c += content_tag(:p, { :class => 'field' }) do
        options = maxlength.nil? ? {} : { :maxlength => maxlength }
        # TODO: might need to add :class to options
        text_area_tag(name, default_value, options)
      end

    end
  end

end
