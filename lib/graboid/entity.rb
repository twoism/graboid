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
        @root_selector ||= inferred_selector
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
        attribute_map.each{|k| puts k.first[:selector]  }
      end
      
      def all_fragments
        doc.css(root_selector).each {|e|  extract_instance e }
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
      def attribute_map
        self.class.attribute_map
      end
    end # InstanceMethods
  end
end