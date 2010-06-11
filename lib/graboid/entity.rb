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
      
      def field name, opts={}, &block
        opts.merge!(:selector   => ".#{name}")  unless opts[:selector].present?
        opts.merge!(:processor  => block)       if block_given?
        
        attribute_map[name] = opts
      end
      
      def root selector
        @root_selector = selector
      end
      
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
          extracted_hash[at.first]  = processor.nil? ? fragment.css(selector).first.text : processor.call(fragment.css(selector).first)
          extracted_hash
        end
      end
      
      def all_fragments
        doc.css root_selector
      end
      
      def all
        all_fragments.collect{ |frag| extract_instance(frag) }
      end
      
      def read_source
        case @source
          when /^http:\/\//
            open @source
          when String
            @source
        end
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