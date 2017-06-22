require 'opencv'
include OpenCV
p SimpleBlobDetector

image = nil
begin
  image = CvMat.load('/Users/takatoigo/photo_to_excel/public/uploads/post/photo/4/2017055d154210.jpg', CV_LOAD_IMAGE_COLOR) # Read the file.
rescue
  puts 'Could not open or find the image.'
  exit
end

window = GUI::Window.new('Display window') # Create a window for display.
window.show(image) # Show our image inside it.
GUI::wait_key # Wait for a keystroke in the window.
