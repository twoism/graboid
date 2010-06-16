module Graboid
  module Scraper
    def self.included klass
      klass.class_eval do
        extend  ClassMethods
        include InstanceMethods
        
        write_inheritable_attribute(:attribute_map, {}) if attribute_map.nil?
      end
    end
    
    module ClassMethods
      
      def attribute_map
        read_inheritable_attribute :attribute_map
      end
      
      def inferred_selector
        @inferred_selector ||= ".#{self.to_s.underscore}"
      end
      
      def root_selector
        @root_selector || inferred_selector
      end
      
      def selector selector
        @root_selector = selector
      end
          
      alias_method :root, :selector

      def set name, opts={}, &block
        opts.merge!(:selector   => ".#{name}")  unless opts[:selector].present?
        opts.merge!(:processor  => block)       if block_given?
        
        attribute_map[name] = opts
      end

    end
    
    module InstanceMethods
      def initialize opts={}, &block
        raise ArgumentError unless opts[:source].present?
        self.source = opts[:source]
      end
      
      def doc
        eval "Nokogiri::#{self.mode.to_s.upcase}(read_source)"
      end
      
      def mode
        @mode ||= :html
      end
      
      def mode=(m)
        raise ArgumentError unless [:html, :xml].include?(m)
        @mode = m
      end
      
      def read_source
        case self.source
          when /^http[s]?:\/\//
            open self.source
          when String
            self.source
        end
      end
      
      def source
        @source
      end
      
      def source=(src)
        @source = src
      end
    end
  end
end