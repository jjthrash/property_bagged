module PropertyBagged
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def property_bag_with_name(property_bag_name)
      class_eval <<-END
        def property_bag
          r = read_attribute #{property_bag_name.to_sym.inspect}
          if String === r
            YAML.load(r)
          else
            r || {}
          end
        end

        def property_bag=(val)
          write_attribute(#{property_bag_name.to_sym.inspect}, val)
        end
      END
    end

    def bagged_property(property_name, options = {})
      default = options[:default]
      class_eval <<-END
        def #{property_name}
          self.property_bag['#{property_name.to_s}'] ||= #{default.inspect}
        end

        def #{property_name}=(val)
          self.property_bag ||= {}
          self.property_bag = self.property_bag.merge('#{property_name}' => val)
        end
      END
    end
  end
end

ActiveRecord::Base.send(:include, PropertyBagged)
