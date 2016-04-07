require "spec_helper"

describe AwesomeTranslations::CleanUpsController do
  let!(:original_file_path) { translation_value.file_path }
  let!(:translation_key) { create :translation_key, key: "some.key" }
  let!(:translation_value) { create :translation_value, translation_key: translation_key, locale: "da", file_path: "#{Rails.root}/config/locales/awesome_translations/some_file.yml" }
  let(:content) do
    {
      "da" => {
        "some" => {
          "key" => "something"
        }
      }
    }
  end

  before do
    FileUtils.mkdir_p(File.dirname(translation_value.file_path))

    File.open(translation_value.file_path, "w") do |fp|
      fp.write(YAML.dump(content))
    end
  end

  it "works" do
    visit new_clean_up_path
    expect(page).to have_http_status(:success)

    # Expect to find
    find(".translation-value[data-id='#{translation_value.id}']")
    find("input[type=submit]").click

    expect { translation_value.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
    expect(File.exist?(original_file_path)).to eq false
  end
end
