# frozen_string_literal: true

require_relative '../../plugin_helper'

describe CustomWizard::StepSerializer do
  fab!(:user) { Fabricate(:user) }
  let(:wizard_template) { get_wizard_fixture("wizard") }
  let(:required_data_json) { get_wizard_fixture("step/required_data") }

  before do
    CustomWizard::Template.save(wizard_template, skip_jobs: true)
    @wizard = CustomWizard::Builder.new("super_mega_fun_wizard", user).build
  end

  it 'should return basic step attributes' do
    json_array = ActiveModel::ArraySerializer.new(
      @wizard.steps,
      each_serializer: described_class,
      scope: Guardian.new(user)
    ).as_json
    expect(json_array[0][:title]).to eq("Text")
    expect(json_array[0][:description]).to eq("<p>Text inputs!</p>")
    expect(json_array[1][:index]).to eq(1)
  end

  it 'should return fields' do
    json_array = ActiveModel::ArraySerializer.new(
      @wizard.steps,
      each_serializer: described_class,
      scope: Guardian.new(user)
    ).as_json
    expect(json_array[0][:fields].length).to eq(4)
  end

  context 'with required data' do
    before do
      enable_subscription("standard")
      wizard_template['steps'][0]['required_data'] = required_data_json['required_data']
      wizard_template['steps'][0]['required_data_message'] = required_data_json['required_data_message']
      CustomWizard::Template.save(wizard_template)
      @wizard = CustomWizard::Builder.new("super_mega_fun_wizard", user).build
    end

    it 'should return permitted attributes' do
      json_array = ActiveModel::ArraySerializer.new(
        @wizard.steps,
        each_serializer: described_class,
        scope: Guardian.new(user)
      ).as_json
      expect(json_array[0][:permitted]).to eq(false)
      expect(json_array[0][:permitted_message]).to eq("Missing required data")
    end
  end
end
