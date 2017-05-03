class PhotoResize < Middleman::Extension
  EXTENSIONS = Set.new(%w[.png .jpg .jpeg])

  option :path_name
  option :sizes

  expose_to_template :each_photo_and_size

  attr_reader :sizes, :src_path, :dst_path

  def initialize(*args)
    super

    # sort highest to lowest
    @sizes = options.sizes.sort { |a, b| b.last <=> a.last }

    src_base = File.join(Dir.pwd, 'source', options.path_name)

    @src_path = File.join(src_base, '*')
    @dst_path = File.join(Dir.pwd, 'source', 'images', options.path_name)

    @metadata = YAML.load_file(File.join(src_base, 'metadata.yml'))
    @metadata ||= {}

    FileUtils.mkdir_p @dst_path
  end

  def photo_metadata
    @photo_metadata ||= YAML.load_file('./source/photos') || Hash.new
  end

  def after_configuration
    Dir[src_path].each do |photo|
      next unless EXTENSIONS.include? File.extname(photo)

      file_name = parameterize(File.basename(photo))

      sizes.each do |name, size|
        dst = File.join(dst_path, "#{name}-#{file_name}")

        system "convert -quality 100 -resize #{size} #{photo} #{dst}"
      end
    end
  end

  def each_photo_and_size
    (Dir[src_path] * 2).each.with_index do |photo|
      next unless EXTENSIONS.include? File.extname(photo)

      file_name = parameterize(File.basename(photo))
      metadata = @metadata.fetch(File.basename(photo, '.*'), {})

      yield PhotoSet.new(metadata, sizes.map { |name, size|
        ["photos/#{name}-#{file_name}", size, metadata]
      })
    end
  end

  protected

  def parameterize(str)
    str.gsub(/[ _]/, '-').downcase
  end

  class PhotoSet
    include Enumerable

    attr_reader :metadata

    def initialize(metadata, photos)
      @metadata = Hash[metadata.map { |key, val| [key.to_sym, val] }]
      @photos = photos
    end

    def size
      @photos.size
    end

    def each(&block)
      @photos.each(&block)
    end

    %w[caption alt].each do |type|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def has_#{type}?
          @metadata.has_key? :#{type}
        end

        def #{type}
          @metadata[:#{type}]
        end
      RUBY_EVAL
    end
  end
end

Middleman::Extensions.register(:photo_resize, PhotoResize)
