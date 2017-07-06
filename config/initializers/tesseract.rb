require 'tesseract'
e = Tesseract::Engine.new { |e|
    e.language = :eng
    e.whitelist = '123456790.'
}
