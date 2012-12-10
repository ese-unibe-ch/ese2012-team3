# This Module defines some cusom ruby "language extensions" if you will to make our lives easier.
module ModelHelpers

  # raises an exception if v is nil or not kind of class (that is , has class as one of its superclasses)
  def assert_kind_of(kclass,v)
    raise "\n<#{v}> expected to be kind_of?
  <#{kclass.name}> but was
  <#{v.class.name}>."  unless v.kind_of?(kclass)
  end

  #
  # Defines an attribute accessor where attributes are
  # only accessible when the given object is editable.
  #
  # An object using this attribute accessor has to
  # implement a method #editable?
  #
  # Wow, this is quite some ruby magic going on...
  def attr_accessor_only_if_editable(*args)
    args.each do |attr_name|
      attr_name = attr_name.to_s

      #getter
      self.class_eval %Q{
          def #{attr_name}
            @#{attr_name}
          end
        }

      #setter
      self.class_eval %Q{
          def #{attr_name}=(val)
            fail "Not editable!" unless self.editable?

            # set the value itself
            @#{attr_name}=val
          end
        }
    end
  end

  # An attribute definition helper.
  # Parameters: supply in the order Class, varname, Class, varname,...
  # This ensures that values set for varname can only be kind_of Class or nil.
  # e.g. <tt>attr_accessor_typesafe String, :text</tt> creates the attribute text and enfores that it is only assigned string values or nil.
  def attr_accessor_typesafe(*classes_args)
    classes_args.each_with_index do |attr_name, i|
      next if i%2 == 0

      class_name = classes_args[i-1].name
      attr_name = attr_name.to_s

      #getter
      self.class_eval %Q{
          def #{attr_name}
            fail "variable <#{attr_name}> accessed without being initialized" unless defined? @#{attr_name}
            @#{attr_name}
          end
        }

      #setter
      self.class_eval %Q{
          def #{attr_name}=(val)
            assert_kind_of(#{class_name}, val) if val != nil

            # set the value itself
            @#{attr_name}=val
          end
        }
    end
  end

  # Same as {attr_accessor_typesafe} but additionally ensures assigned values are not nil
  def attr_accessor_typesafe_not_nil(*classes_args)
    classes_args.each_with_index do |attr_name, i|
      next if i%2 == 0

      class_name = classes_args[i-1].name
      attr_name = attr_name.to_s

      #getter
      self.class_eval %Q{
          def #{attr_name}
            fail "variable <#{attr_name}> accessed without being initialized" unless defined? @#{attr_name}
            @#{attr_name}
          end
        }

      #setter
      self.class_eval %Q{
          def #{attr_name}=(val)
            assert_kind_of(#{class_name}, val)

            # set the value itself
            @#{attr_name}=val
          end
        }
    end
  end

 end

# @internal_note Test::Unit::Assertions::assert_kind_of does the same as ModelHelpers::assert_kind_of, but the stacktrace gets longer (5 levels of unrelated code versus 1 level...)
#   use the following code to use it instead: 
#   require "test/unit"
#   include Test::Unit::Assertions

include ModelHelpers
