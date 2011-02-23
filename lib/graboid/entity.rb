module Graboid
  module Entity

    def self.included klass
      klass.class_eval do
        extend  ClassMethods
        include InstanceMethods

        inherited_attributes :attribute_map
        @attribute_map = {}
      end
    end

    module ClassMethods

      def inherited_attributes(*args)
        @inherited_attributes ||= [:inherited_attributes]
        @inherited_attributes += args
        args.each do |arg|
          class_eval %(
            class << self; attr_accessor :#{arg} end
          )
        end
        @inherited_attributes
      end

      def inherited(subclass)
        @inherited_attributes.each do |inheritable_attribute|
          instance_var = "@#{inheritable_attribute}"
          subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
        end
      end

      def source
        @source
      end

      def source=(src)
        @source = src
      end

      def set name, opts={}, &block
        opts.merge!(:selector   => ".#{name}")  if opts[:selector].nil?
        opts.merge!(:processor  => block)       if block_given?

        attribute_map[name] = opts
      end

      alias_method :field, :set

      def selector selector
        @root_selector = selector
      end

      alias_method :root, :selector

      def root_selector
        @root_selector || inferred_selector
      end

      def inferred_selector
        @inferred_selector ||= ".#{self.to_s.underscore}"
      end

      def doc
        eval "Nokogiri::#{self.mode.to_s.upcase}(read_source)"
      end

      def collection
        @collection ||= []
      end

      def collection=(col)
        @collection = col
      end

      def attribute_map
        read_inheritable_attribute :attribute_map
      end

      def extract_instance fragment
        new(hash_map(fragment))
      end

      def hash_map fragment
        attribute_map.inject({}) do |extracted_hash, at| 
          selector, processor       = at.last[:selector], at.last[:processor]
          node_collection           = self.mode == :html ? fragment.css(selector) : fragment.xpath(selector)
          extracted_hash[at.first]  = processor.nil? ? node_collection.first.inner_html : processor.call(node_collection.first) #rescue ""

          extracted_hash
        end
      end

      def all_fragments
        return page_fragments if @pager.nil?
        old_source = self.source
        while next_page?
          self.collection += page_fragments
          run_before_paginate_callbacks
          paginate
          run_after_paginate_callbacks
        end
        self.source = old_source
        self.collection
      end

      def paginate
        next_page_url = @pager.call(doc) rescue nil
        self.source   = next_page_url
        self.current_page += 1
      end

      def next_page?
        if max_pages.zero?
          return true unless @pager.call(doc).nil?
        else
          current_page <= max_pages-1
        end
      end

      def page_fragments
        doc.css(root_selector)
      end

      def all opts={}
        reset_context
        self.max_pages = opts[:max_pages] unless opts[:max_pages].nil?
        all_fragments.collect{ |frag| extract_instance(frag) }
      end

      def reset_context
        self.collection   = []
        self.current_page = 0
        self.max_pages    = 0
      end

      def read_source
        case self.source
          when /^http[s]?:\/\//
            open(self.source, "User-Agent" => Graboid.user_agent)
          when String
            self.source
        end
      end

      def pager &block
        @pager = block
      end

      def mode
        @mode ||= :html
      end

      def mode=(m)
        raise ArgumentError unless [:html, :xml].include?(m)
        @mode = m
      end

      def max_pages
        @max_pages ||= 0
      end

      def max_pages=num
        @max_pages = num
      end

      def current_page
        @current_page ||= 0
      end

      def current_page=num
        @current_page = num
      end

      instance_eval do
        [:before, :after].each do |prefix|
          [:paginate, :extract].each do |suffix|
            method_name = "#{prefix}_#{suffix}"
            define_method method_name.to_sym do |&block|
              instance_variable_set "@#{method_name}", block
            end
            define_method "run_#{method_name}_callbacks" do
              ivar = instance_variable_get("@#{method_name}")
              class_eval { ivar.call } unless ivar.nil?
            end
          end
        end
      end

    end # ClassMethods

    module InstanceMethods

      def initialize opts={}
        opts.each do |k,v|
          self.class.class_eval do
            define_method k do
              v
            end
          end
        end
      end

      def attribute_map
        self.class.attribute_map
      end
    end # InstanceMethods
  end
end
