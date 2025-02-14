# frozen_string_literal: true

require 'rspec'
require_relative '../lib/curseforge'

# TODO: actual tests lol
client = CurseForge.new(ENV["CURSEFORGE_TOKEN"])
describe CurseForge do
  it 'can get mod' do
    expect { client.get_mod(264_231) }.not_to raise_error
  end

  it 'can get mods' do
    expect { client.get_mods(264_231) }.not_to raise_error
  end

  it 'can get mods from manifest' do
    file = File.open(__dir__ + '/manifest.json')
    manifest = JSON.parse(file.read)
    file.close
    expect { client.get_mods_from_manifest(manifest) }.not_to raise_error
  end
end
