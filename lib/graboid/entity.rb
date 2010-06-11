module Graboid
  module Entity
    
    def self.included klass
      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods
      
      def source
        @source
      end

      def source=(src)
        @source = src
      end
      
      def root selector
        @root_selector = selector
      end
      
      def root_selector
        @root_selector ||= ".#{self.to_s.underscore}"
      end
    end # ClassMethods
    
    module InstanceMethods
    end # InstanceMethods
  end
end