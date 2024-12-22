# frozen_string_literal: true

require 'faraday'

# CurseForge API Wrapper
# by PackBuilder.io
class CurseForge
  require_relative 'curseforge/version'

  def initialize(token)
    @token = token
    @api = Faraday.new(
      url: 'https://api.curseforge.com',
      headers: { 'x-api-key' => @token }
    )
  end

  # @param [Integer] mod_id
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#schemaget%20mod%20response
  def get_mod(mod_id)
    get_request("/v1/mods/#{mod_id}")
  end

  # @param [Array<Integer>] mod_ids
  # @param [Boolean] filter_pc_only
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#schemaget%20mods%20response
  def get_mods(*mods_ids, filter_pc_only: true)
    post_request('/v1/mods', body: {
                   modIds: mods_ids,
                   filterPCOnly: filter_pc_only
                 }, headers: { 'Content-Type' => 'application/json' })
  end

  # @param [Hash] json
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#schemaget%20mods%20response
  # @example
  #  require 'json'
  #  require 'curseforge'
  #
  #  file = File.open('manifest.json')
  #  json = JSON.parse(file.read)
  #  file.close
  #  client = CurseForge.new('token')
  #  mods = client.get_mods_from_manifest(json)
  def get_mods_from_manifest(json)
    get_mods(json['files'].map(&:projectID))
  end

  # Filters mods based on the given query parameters.
  #
  # @param [Integer] game_id Filter by game ID.
  # @param [Hash] query
  # @option query [Integer] classId Filter by section ID.
  # @option query [Integer] categoryId Filter by category ID.
  # @option query [String] categoryIds Filter by a list of category IDs (overrides <tt>categoryId</tt>)
  # @option query [String] gameVersion Filter by game version string
  # @option query [String] gameVersions Filter by a list of game version strings (overrides <tt>gameVersion</tt>)
  # @option query [String] searchFilter Free text search in the mod name and author
  # @option query [String] sortField Filter by <tt>ModsSearchSortField</tt> enumeration
  # @option query [String] sortOrder <tt>asc</tt> for ascending, <tt>desc</tt> for descending
  # @option query [String] modLoaderType Filter mods associated with a specific modloader (requires <tt>gameVersion</tt>)
  # @option query [String] modLoaderTypes Filter by a list of mod loader types (overrides <tt>modLoaderType</tt>)
  # @option query [Integer] gameVersionTypeId Filter mods tagged with versions of the given <tt>gameVersionTypeId</tt>
  # @option query [Integer] authorId Filter by mods authored by the given <tt>authorId</tt>
  # @option query [Integer] primaryAuthorId Filter by mods owned by the given <tt>primaryAuthorId</tt>
  # @option query [String] slug Filter by slug (use with <tt>classId</tt> for unique result)
  # @option query [Integer] index **Zero-based** index of the first item to include in the response (max: <tt>index + pageSize <= 10,000</tt>)
  # @option query [Integer] pageSize Number of items to include in the response (default/max: 50).
  #
  # @raise [Faraday::Error]
  # @return [Hash] Filtered mods based on the query parameters.
  # @see https://docs.curseforge.com/rest-api/#schemasearch%20mods%20response
  def search_mods(game_id, **query)
    query[:gameId] = game_id
    get_request('/v1/mods/search', body: query)
  end

  private

  def req(method, path, body: nil, headers: nil)
    # TODO: actual error handling
    @api.send(method, path, body, headers).body
  end

  %i[get post put delete].each do |method|
    define_method(:"#{method}_request") do |path, body: nil, headers: nil|
      req(method, path, body: body, headers: headers)
    end
  end
end
