Pod::Spec.new do |s|
  s.name         = "FTPDFIconRenderer"
  s.version      = "0.0.1"
  s.summary      = "Resolution independent images in iOS applications based on PDF."
  s.description  = <<-DESC
                    Creates scaled UIImages from PDFs while keeping the device’s main
                    screen scale factor in account. PDFs can also be treated as masks,
                    allowing you to render one image into mutiple color variants. All
                    generated images are cached, on disk, by default.
                   DESC
  s.homepage     = "https://github.com/Fingertips/FTPDFIconRenderer"
  s.license      = 'MIT'
  s.author       = { "Eloy Durán" => "eloy.de.enige@gmail.com" }
  s.source       = { :git => "https://github.com/Fingertips/FTPDFIconRenderer.git" }
  s.platform     = :ios, '4.0'
  s.source_files = 'Source'
  s.requires_arc = true
end
