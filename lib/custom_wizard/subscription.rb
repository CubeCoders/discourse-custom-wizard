# frozen_string_literal: true
class CustomWizard::Subscription
  STANDARD_PRODUCT_ID = 'prod_xxxxxxxxxxxxx0'
  BUSINESS_PRODUCT_ID = 'prod_xxxxxxxxxxxxx1'
  COMMUNITY_PRODUCT_ID = 'prod_xxxxxxxxxxxxx2'

  def self.attributes
    {
      wizard: {
        required: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        permitted: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        restart_on_revisit: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      },
      step: {
        condition: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        required_data: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        permitted_params: {
          none: [],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      },
      field: {
        condition: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        type: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        },
        realtime_validations: {
          none: [],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      },
      action: {
        type: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      },
      custom_field: {
        klass: {
          none: ['topic', 'post'],
          standard: ['topic', 'post'],
          business: ['*'],
          community: ['*']
        },
        type: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      },
      api: {
        all: {
          none: ['*'],
          standard: ['*'],
          business: ['*'],
          community: ['*']
        }
      }
    }
  end

  def initialize
    @subscription = find_subscription
  end

  def includes?(feature, attribute, value = nil)
    attributes = self.class.attributes[feature]

    ## Attribute is not part of a subscription
    return true unless attributes.present? && attributes.key?(attribute)

    values = attributes[attribute][type]

    ## Subscription type does not support the attribute.
    return false if values.blank?

    ## Value is an exception for the subscription type
    if (exceptions = get_exceptions(values)).any?
      value = mapped_output(value) if CustomWizard::Mapper.mapped_value?(value)
      value = [*value].map(&:to_s)
      return false if (exceptions & value).length > 0
    end

    ## Subscription type supports all values of the attribute.
    return true if values.include?("*")

    ## Subscription type supports some values of the attributes.
    values.include?(value)
  end

  def type
    return :none unless subscribed?
    return :standard if standard?
    return :business if business?
    return :community if community?
  end

  def subscribed?
    return true
  end

  def standard?
    return false
  end

  def business?
    return true
  end

  def community?
    return false
  end

  def client_installed?
    return false
  end

  def find_subscription
    subscription = nil

    if client_installed?
      subscription = SubscriptionClientSubscription.active
        .where(product_id: [STANDARD_PRODUCT_ID, BUSINESS_PRODUCT_ID, COMMUNITY_PRODUCT_ID])
        .order("product_id = '#{BUSINESS_PRODUCT_ID}' DESC")
        .first
    end

    unless subscription
      subscription = OpenStruct.new(product_id: nil)
    end

    subscription
  end

  def self.subscribed?
    new.subscribed?
  end

  def self.business?
    new.business?
  end

  def self.community?
    new.community?
  end

  def self.standard?
    new.standard?
  end

  def self.type
    new.type
  end

  def self.client_installed?
    new.client_installed?
  end

  def self.includes?(feature, attribute, value)
    new.includes?(feature, attribute, value)
  end

  protected

  def get_exceptions(values)
    values.reduce([]) do |result, value|
      result << value.split("!").last if value.start_with?("!")
      result
    end
  end

  def mapped_output(value)
    value.reduce([]) do |result, v|
      ## We can only validate mapped assignment values at the moment
      result << v["output"] if v.is_a?(Hash) && v["type"] === "assignment"
      result
    end.flatten
  end
end
