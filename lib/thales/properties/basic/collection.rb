
module Properties
  module Basic

    class Collection
      include ActiveModel::Validations
      validates_presence_of :title, :description

      #include ActiveModel::Serialization
      #attr_accessor :attributes

      attr_accessor :title
      attr_accessor :alt_titles
      attr_accessor :description
      attr_accessor :keywords
      attr_accessor :urls
      attr_accessor :rights_access
      attr_accessor :rights_licence
      attr_accessor :rights_statement

      def initialize(attr = nil)
        if attr
          @title = attr['title']
          @alt_titles = get_array_values(attr['altTitle'])
          @description = attr['description']
          @keywords = get_array_values(attr['keyword'])
          @urls = get_array_values(attr['url'])
          @rights_access = attr['rights_access']
          @rights_statement = attr['rights_statement']
          @rights_licence = attr['rights_licence']
        else
          @alt_titles = []
          @keywords = []
          @urls = []
        end
      end

      def get_array_values(h)
        # TODO: since the keys are strings, this will fail when > 10
        result = h.keys.sort.map { |key| h[key] }
        result.select { |str| (! str.blank?) }
      end

      def to_key
        ['42']
      end

      def serialize
        YAML::dump(self)
      end

      def self.deserialize(str)
        YAML::load(str)
      end

    end # class Collection

  end
end

#    hash = JSON.parse(str, :symbolize_names => true)
#
#    @title = hash[:title]
#    @alternative_titles = hash[:alternative_titles]
#    if @alternative_titles.nil?
#      @alternative_titles = []
#    end
#    @url = hash[:url]
#  end
#
#  def to_s
##    JSON.generate(self)
#    "foo"
#  end
#
#  def to_json(*a)
#    {
#      :title => @title,
#      :alternative_titles => @alternative_titles,
#      :url => @url,
#    }.to_json(*a)
#  end
#end
