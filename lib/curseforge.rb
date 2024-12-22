# frozen_string_literal: true

require_relative "curseforge/version"
require "faraday"

class Curseforge
  def initialize(token) 
    @token = token
  end

  def getModData(projectId) 
    begin
      response = Faraday.get("https://api.curseforge.com/v1/mods/" + projectId, nil, {
        "x-api-key": @token
      })
    rescue Faraday::Error => e
      # You can handle errors here (4xx/5xx responses, timeouts, etc.)
      puts e.response[:status]
      puts e.response[:body]
    end
    
    # At this point, you can assume the request was successful
    return response.body
  end
end
