# frozen_string_literal: true

require 'faraday'
require 'json'

# CurseForge API Wrapper
# by PackBuilder.io
class CurseForge
  require_relative 'curseforge/version'
  require_relative 'curseforge/error'

  def initialize(token, **options)
    @token = token

    options[:url] ||= 'https://api.curseforge.com'
    options[:headers] ||= {}
    options[:headers]["x-api-key"] = @token
    @api = Faraday.new(options)
  end

  # @param [Integer] mod_id
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#get-mod
  def get_mod(mod_id)
    req(:get, "/v1/mods/#{mod_id}")
  end

  # @param [Array<Integer>] mod_ids
  # @param [Boolean] filter_pc_only
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#get-mods
  def get_mods(*mods_ids, filter_pc_only: true)
    req(:post, '/v1/mods', body: {
                   modIds: mods_ids,
                   filterPCOnly: filter_pc_only
                }.to_json, headers: { 'Content-Type' => 'application/json' })["data"]
  end

  # @param [Hash] json
  # @raise [Faraday::Error]
  # @return [Hash]
  # @see https://docs.curseforge.com/rest-api/#get-mods
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
    get_mods(*json['files'].map { |f| f['projectID'] })
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
    req(:get, '/v1/mods/search', body: query)
  end

  private

    def req(method, path, body: nil, headers: nil)
      resp = @api.send(method, path, body, headers)
      raise CurseForge::Error.new(resp, "received #{resp.status}") unless resp.success?

      JSON.parse(resp.body)
    rescue JSON::ParserError => e
      raise CurseForge::Error.new(resp, e.message)
    end
end
