require 'mongoid'
require 'mongoid/slugify/version'
require 'active_support/concern'

module Mongoid
  module Slugify
    def self.at_least_mongoid3?
      defined?(Mongoid::VERSION) && Gem::Version.new(Mongoid::VERSION) >= Gem::Version.new('3.0.0')
    end

    extend ActiveSupport::Concern

    included do
      field :slug
      if Mongoid::Slugify.at_least_mongoid3?
        index({ :slug => 1 }, { :unique => true })
      else
        index :slug, :unique => true
      end
      before_save :assign_slug, :if => :assign_slug?
    end

    module ClassMethods
      def find_by_slug(slug)
        where(:slug => slug).first
      end

      def find_by_slug!(slug)
        find_by_slug(slug) || raise(Mongoid::Errors::DocumentNotFound.new(self, { :slug => slug }))
      end

      def find_by_slug_or_id(slug_or_id)
        find_by_slug(slug_or_id) || where(:_id => slug_or_id).first
      end

      def find_by_slug_or_id!(slug_or_id)
        find_by_slug(slug_or_id) || where(:_id => slug_or_id).first || raise(Mongoid::Errors::DocumentNotFound.new(self, { :slug => slug_or_id }))
      end
    end

    def to_param
      slug || super
    end

    private
    def assign_slug?
      true
    end

    def generate_slug
      raise NotImplementedError
    end

    def generate_unique_slug
      current_slug = generate_slug
      pattern = /^#{Regexp.escape(current_slug)}(?:-(\d+))?$/

      appropriate_class = self.class
      while (appropriate_class.superclass.include?(Mongoid::Document))
        appropriate_class = appropriate_class.superclass
      end

      existing_slugs = appropriate_class.where(:slug => pattern, :_id.ne => _id).only(:slug).map { |record| record.slug }
      if existing_slugs.count > 0
        max_counter = existing_slugs.map { |slug| (pattern.match(slug)[1] || 0).to_i }.max
        current_slug << "-#{max_counter + 1}"
      end

      current_slug
    end

    def assign_slug
      self.slug = generate_unique_slug
    end
  end
end
