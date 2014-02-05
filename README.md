# Carta

Carta is a command line tool to aid in the ebook creation workflow. Initially it will support the HTML and EPUB formats.

## Installation

Add this line to your application's Gemfile:

    gem 'carta'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carta --pre

## Usage

    $ carta book
Walks you through a book project creation process.

    $ carta chapter [number] [name]
Will create a markdown file in the correct place with the name you specify.
numbers formatted like `1.1` will create a folder that matches the correct heirarchy and then create an H# tag with the correct level. Following these formats help generate a well formed table of contents

    $ carta compile
Will generate a build folder with the compiled files in it.

## TODO
* Add partial support
* Remove html generation from the cli codebase
* Maybe switch to tilt for templates
* Improve chapter creation (not intuitive atm)
* Improve status messages
* Use thor for more of the template rendering/etc.
* Integrate SCSS/etc.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/carta/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
