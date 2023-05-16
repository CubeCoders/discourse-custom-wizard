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
          none: ['*'],
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
          none: ['*'],
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
    true
  end

  def type
    return :none unless subscribed?
    return :standard if standard?
    return :business if business?
    return :community if community?
  end

  def subscribed?
    true
  end

  def standard?
    @subscription.product_id === STANDARD_PRODUCT_ID
  end

  def business?
    @subscription.product_id === BUSINESS_PRODUCT_ID
  end

  def community?
    @subscription.product_id === COMMUNITY_PRODUCT_ID
  end

  def client_installed?
    defined?(SubscriptionClient) == 'constant' && SubscriptionClient.class == Module
  end

  def find_subscription
    subscription = nil
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
