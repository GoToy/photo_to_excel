class Post < ApplicationRecord
  require "opencv"
  mount_uploader :photo, PhotoUploader
  def get_coordinate

    cvmat = OpenCV::CvMat.load(Rails.root.to_s + "/public" + photo_url)
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
        coordinate_data_hash = {}
        coordinate_data_hash[:x] = contour.rect.x
        coordinate_data_hash[:y] = contour.rect.y
        coordinate_data_hash[:h] = contour.rect.height
        coordinate_data_hash[:w] = contour.rect.width
        coordinate_data_array << coordinate_data_hash
      end
    end

    coordinate_data_array
  end

  def absolute_photo_path
    Rails.root.to_s + "/public" + self.photo_url
  end
end
