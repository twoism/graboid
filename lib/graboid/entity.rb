module Graboid
  module Entity
    
    def self.included klass
      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
        write_inheritable_attribute(:attribute_map, {}) if attribute_map.nil?
      end
    end
    
    module ClassMethods
      
      def source
        @source
      end
      
      def source=(src)
        @source = src
      end
      
      def set name, opts={}, &block
        opts.merge!(:selector   => ".#{name}")  unless opts[:selector].present?
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
        Nokogiri::HTML read_source
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
          extracted_hash[at.first]  = processor.nil? ? fragment.css(selector).first.text : processor.call(fragment.css(selector).first) rescue ""

          extracted_hash
        end
      end
      
      def all_fragments
        return page_fragments if @pager.nil?
        old_source  = self.source
        @collection = []
        while next_page?
          @frags = page_fragments
          @collection += @frags
          paginate
        end
        self.source = old_source
        @collection
      end
      
      def paginate
        next_page_url = @pager.call(doc) rescue nil
        self.source   = next_page_url
        self.current_page += 1
      end
      
      def next_page?
        (current_page <= max_pages-1)
      end
      
      def page_fragments
        doc.css(root_selector)
      end
      
      def all opts={}
        self.max_pages = opts[:max_pages] if opts[:max_pages].present?
        all_fragments.collect{ |frag| extract_instance(frag) }
      end
      
      def read_source
        case self.source
          when /^http:\/\//
            open self.source
          when String
            self.source
        end
      end
      
      def pager &block
        @pager = block
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
      
    end # ClassMethods
    
    module InstanceMethods
      
      def initialize opts={}
        opts.each do |k,v|
          self.class_eval do
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