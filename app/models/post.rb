class Post < ApplicationRecord
  require "opencv"
  mount_uploader :photo, PhotoUploader
  def get_coordinate

    cvmat = OpenCV::CvMat.load(self.absolute_photo_path)
    cvmat = cvmat.BGR2GRAY
    canny = cvmat.canny(50, 150)
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

  def formatted_coordinate_data
    contour_array = self.get_coordinate
    coordinate_data_array = []
    contour_array.each do |contour|
      if contour
        if contour.rect.height > 100 && contour.rect.width > 100
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

  def convert2string
    e = Tesseract::Engine.new { |e|
      e.language = :eng
      e.whitelist = '1234567890,'
    }
    original_image = Magick::Image.read(self.absolute_photo_path).first
    num_array = []

    formatted_coordinates = self.formatted_coordinate_data

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
      num_hash[:string] = e.text_for(image).strip
      num_array << num_hash
    end

    num_array
  end
end
