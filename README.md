# Mongoid::Slugify

Mongoid::Slugify is a gem, which helps you with generating slugs for your Mongoid models.

[![Travis CI](https://secure.travis-ci.org/fxposter/mongoid-slugify.png)](http://travis-ci.org/fxposter/mongoid-slugify)

## Installation

Add Mongoid::Slugify to your Gemfile:

```ruby
gem 'mongoid-slugify'
```

Since 0.1.0 Mongoid::Slugify supports both Mongoid 2.x, 3.x and 4.x releases.

## Usage

```ruby
class Product
  include Mongoid::Document
  include Mongoid::Slugify

  field :title

  private
  def generate_slug
    title.parameterize
  end
end
```

As you can see, you should make 2 things:

- include Mongoid::Slugify module to your model
- provide a way to generate initial slug for your model (based on any fields, that you want)

If do those - Mongoid::Slugify will save the generated slug to `slug` field of your model and will care about slug uniqueness (it will append "-1", "-2", etc to your slugs until it finds free one).

Mongooid::Slugify gives you these additional functions:

- redefines `to_param` method, so that it returns slug, if it's present, and model id otherwise
- `Model.(find_by_slug/find_by_slug!/find_by_slug_or_id/find_by_slug_or_id!)` methods.
  If you don't want to generate slugs for all your existing objects (so that to_param will return model ids) - you should prefer the latter two in your controllers.

## Warning

This library will not provide a way to generate initial slugs, at least in the nearest future. I just don't need it. If you need this functionality - please, contact me and we can discuss it. Or simply open pull request. :)

If you need all-out-of-the-box solution - look at [Mongoid Slug](https://github.com/digitalplaywright/mongoid-slug), it's far more full featured and actively developed.
