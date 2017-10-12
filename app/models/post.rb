class Post < ApplicationRecord
  require "opencv"
  require "RMagick"
  require "csv"
  require "chunky_png"

  mount_uploader :photo, PhotoUploader
  def get_coordinate(canny_num_min, canny_num_max)

    cvmat = OpenCV::CvMat.load(self.absolute_photo_path)
    cvmat = cvmat.BGR2GRAY
    canny = cvmat.canny(canny_num_min, canny_num_max)
    contour = canny.find_contours(:mode => OpenCV::CV_RETR_LIST, :method => OpenCV::CV_CHAIN_APPROX_SIMPLE)

    contour_array = []
    while contour
      unless contour.hole?

        box = contour.bounding_rect
        # Draw that bounding rectangle
        cvmat.rectangle! box.top_left, box.bottom_right, :color => OpenCV::CvColor::Black

      end
      contour = contour.h_next
      contour_array << contour
    end

    contour_array
  end

  def formatted_coordinate_data(img_width, x_cell_num, canny_num_min, canny_num_max)
    contour_array = self.get_coordinate(canny_num_min, canny_num_max)
    coordinate_data_array = []
    contour_array.each do |contour|
      if contour
        cell_size =  img_width / x_cell_num
        if (contour.rect.width >  cell_size/4) && (contour.rect.width < cell_size * 5/4) && (contour.rect.height > cell_size/4) && (contour.rect.height < cell_size * 5/4)
          coordinate_data_hash = {}
          coordinate_data_hash[:x] = contour.rect.x
          coordinate_data_hash[:y] = contour.rect.y
          coordinate_data_hash[:h] = contour.rect.height
          coordinate_data_hash[:w] = contour.rect.width
          coordinate_data_array << coordinate_data_hash
        end
      end
    end

    coordinate_data_array
  end

  def absolute_photo_path
    Rails.root.to_s + "/public" + self.photo_url
  end

  def image
     img = Magick::Image.ping( self.absolute_photo_path ).first
     width, height = img.columns, img.rows
  end

  def convert2string(x_cell_num, canny_num_min, canny_num_max)
    e = Tesseract::Engine.new { |e|
      e.language = :eng
      e.whitelist = '0123456789,'
      e.page_segmentation_mode = :single_char
  }
    original_image = Magick::Image.read(self.absolute_photo_path).first
    num_array = []

    formatted_coordinates = self.formatted_coordinate_data(original_image.columns,
                                                           x_cell_num,
                                                           canny_num_min,
                                                           canny_num_max)

    formatted_coordinates.each do |formatted_coordinate|
      image = original_image.crop(formatted_coordinate[:x],
                                  formatted_coordinate[:y],
                                  formatted_coordinate[:w],
                                  formatted_coordinate[:h])
      num_hash = {}
      num_hash[:x] = formatted_coordinate[:x]
      num_hash[:y] = formatted_coordinate[:y]
      num_hash[:w] = formatted_coordinate[:w]
      num_hash[:h] = formatted_coordinate[:h]
      num_hash[:n] = convert2string_fann(image)
      num_array << num_hash
    end

    num_array
  end

  def convert2string_fann(image)
    pixels = image.export_pixels_to_str(0, 0, image.columns, image.rows, 'RGBA')
    canvas = ChunkyPNG::Canvas.from_rgba_stream(image.columns, image.rows, pixels)

    # canvas.save 'input.png'
    canvas.grayscale!
    canvas = center_and_downsample(canvas)
    # canvas.save 'cropped.png'
    random_cropped = 5.times.map { canvas.crop(rand(5), rand(5), 24, 24) }
    predict_sums = Array.new(10, 0)
    random_cropped.each do |cropped|
      pixels = cropped.pixels
      predict = RubyFann::Standard.new(filename: "#{Rails.public_path}/trained_nn_300_60000_7_crop.net").run(pixels)
      predict.each_with_index {|val, i| predict_sums[i] += val}
    end

    decode_prediction(predict_sums)
  end

  def center_and_downsample(canvas)
    canvas.trim!
    canvas = ChunkyPNG::Canvas.new(canvas.width,
                                   canvas.height,
                                   binarize_pixels(canvas))
    size = [canvas.width, canvas.height].max
    square = ChunkyPNG::Canvas.new(size, size, ChunkyPNG::Color::TRANSPARENT)
    offset_x = ((size - canvas.width) / 2.0).floor
    offset_y = ((size - canvas.height) / 2.0).floor
    square.compose! canvas, offset_x, offset_y
    square.resample_bilinear!(20,20)
    square.border! 4, ChunkyPNG::Color::TRANSPARENT
    square
  end

  def binarize_pixels(canvas)
    normalize = -> (val, fromLow, fromHigh, toLow, toHigh) { (val - fromLow) * (toHigh - toLow) / (fromHigh - fromLow).to_f }

    pixels = []
    canvas.height.times do |y|
      canvas.width.times do |x|
        pixels << canvas[x, y]
      end
    end

    max, min = pixels.max, pixels.min
    pixels = pixels.map {|p| normalize.(p, min, max, 0, 255) }
    pixels = pixels.map {|p| p > 126 ? 0 : 255 }
  end

  def decode_prediction(result)
    (0..9).max_by {|i| result[i]}
  end
end
