# -*- coding: utf-8 -*-
module Webtail
  module App
    extend self

    def run
      
      unless Webtail.config[:after_start].nil?
        begin
          cb = eval(File.read(Webtail.config[:after_start]), binding)
        rescue
          ## do nothing
        end
      end

      ::Rack::Handler::WEBrick.run(
        Server.new,
        :Port          => Webtail.config[:port],
        :Logger        => ::WEBrick::Log.new("/dev/null"),
        :AccessLog     => [nil, nil],
        :StartCallback => cb || proc { App.open_browser }
      )
    end

    def open_browser
      ::Launchy.open("http://localhost:#{Webtail.config[:port]}") rescue nil
    end

    class Server < ::Sinatra::Base
      set :webtailrc do
        path = File.expand_path(Webtail.config[:rc])
        File.exist?(path) && File.read(path)
      end
      set :root, File.expand_path("../../../", __FILE__)

      get "/" do
        @web_socket_port = WebSocket.port
        @webtailrc = settings.webtailrc
        erb :index
      end

      post "/" do
        Webtail.channel << params[:text]
      end
    end
  end
end
