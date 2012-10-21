require 'active_support/inflector/methods'
require 'json'

module Jongoid
  module Document
    extend ActiveSupport::Concern

    def collection; self.class.collection; end

    def new_record?; !!@_mongo_data[:_id]; end

    def save
      query = collection.find(_id: self._id)

      record = query.first

      q = if record
        query.update(@_mongo_data)
      else
        collection.insert(@_mongo_data)
      end
    end

    def initialize(params = {})
      params = Jongoid::Document.symbolize_hash(params)

      params.delete(:id)
      params.delete(:_id)

      @_mongo_data = params.merge(_id: Jongoid::Document.generate_id)
    end

    def inspect
      "#<#{self.class}:#{@_mongo_data.to_json[1..-2].gsub(/:/, '=')}>"
    end

    def to_s
      inspect
    end

    def to_json(*a)
      @_mongo_data.to_json(*a)
    end

    def to_hash
      @_mongo_data
    end

    def method_missing(method, value = nil)
      if method[-1] == "="
        method = method[0..-2].to_sym
        return super if not self.class.fields.keys.include?(method)
        @_mongo_data[method] = value
      else
        method = method.to_sym
        return super if not self.class.fields.keys.include?(method)
        @_mongo_data[method]
      end
    end

    module ClassMethods
      def mongo; Checkers::API.mongo; end

      def collection_name; ActiveSupport::Inflector.underscore(self.to_s).to_sym; end

      def collection; mongo[collection_name]; end

      def fields; @fields || {}; end

      def field(name, opts = {})
        @fields ||= { :_id => {} }
        @fields[name] = opts
      end

      def first(criteria = {})
        raise "Must be Hash" if not criteria.is_a?(Hash)

        data = collection.where(criteria).first
        return nil unless data
        data = Jongoid::Document.symbolize_hash(data)
        doc = self.new data
        doc._id = data[:_id]
        doc
      end

      def all(criteria = {})
        raise "Must be Hash" if not criteria.is_a?(Hash)

        datas = collection.where(criteria)
        datas.map do |data|
          sym_data = Jongoid::Document.symbolize_hash(data)
          doc = self.new sym_data
          doc._id = sym_data[:_id]
          doc
        end
      end

      def find(id)
        raise "Must be String" if not id.is_a?(String)
        first(_id: id)
      end

    end

    def self.symbolize_hash(hsh)
      Hash[hsh.to_a.map{|a, b| [a.to_sym, b] }]
    end

  private
    def self.generate_id
      rand(36**24).to_s(36)
    end

  end

  # class Criteria
  # end
end
