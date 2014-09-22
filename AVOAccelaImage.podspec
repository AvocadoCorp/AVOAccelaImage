Pod::Spec.new do |s|
  s.name         = 'AVOAccelaImage'
  s.version      = '0.1.3'
  s.summary      = 'Avocado Image Utils using the Accelerate framework.'
	s.homepage		 = "https://github.com/AvocadoCorp/AVOAccelaImage"
  s.authors      = { 'Ben D. Jones' => 'ben@avocado.io' }
  s.source       = { :git => 'https://github.com/AvocadoCorp/AVOAccelaImage.git', :tag => s.version.to_s }
  s.source_files = '*.{h,m}'
  s.framework    = 'Accelerate'
  s.ios.deployment_target = '6.0'
	s.requires_arc = true
	s.license      = {
	    :type => 'MIT',
	    :text => <<-LICENSE
	              The MIT License (MIT)

Copyright (c) 2014 Avocado, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
	    LICENSE
	  }
end
