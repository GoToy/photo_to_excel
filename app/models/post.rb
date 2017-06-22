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
end
