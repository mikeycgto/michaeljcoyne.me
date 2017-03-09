class PhotoResize < Middleman::Extension
  option :path_name
  option :sizes

  expose_to_template :each_photo_and_size

  attr_reader :sizes, :src_path, :dst_path

  def initialize(*args)
    super

    # sort highest to lowest
    @sizes = options.sizes.sort { |a, b| b.last <=> a.last }

    @src_path = File.join(Dir.pwd, 'source', options.path_name, '*')
    @dst_path = File.join(Dir.pwd, 'source', 'images', options.path_name)

    FileUtils.mkdir_p @dst_path
  end

  def after_configuration
    Dir[src_path].each do |photo|
      file_name = parameterize(File.basename(photo))

      sizes.each do |name, size|
        dst = File.join(dst_path, "#{name}-#{file_name}")

        fork do
          system "convert -quality 100 -resize #{size} #{photo} #{dst}"
        end
      end
    end
  end

  def each_photo_and_size
    Dir[src_path].each.with_index do |photo|
      file_name = parameterize(File.basename(photo))

      yield sizes.map { |name, size|
        ["photos/#{name}-#{file_name}", size]
      }
    end
  end

  protected

  def parameterize(str)
    str.gsub(/[ _]/, '-').downcase
  end
end

Middleman::Extensions.register(:photo_resize, PhotoResize)
