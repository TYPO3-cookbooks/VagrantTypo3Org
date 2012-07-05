#
# Cookbook Name:: typo3
# Recipe:: tools
#
# Copyright 2012, Christian Trabold, Sebastiaan van Parijs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Load useful and required tools needed for TYPO3 to run
# This is just a plain list of tools.
# You may use cookbooks for that.
# Tested on ubuntu 10.04 only

case node[:platform]
when "centos","redhat","fedora","suse"
  # Not supported at the moment
when "debian","ubuntu"

  %w{
  catdoc
  ghostscript
  libgs8
  libphp-adodb
  xpdf-common
  xpdf-utils
  exiftags
  }.each do |pkg|
    package pkg do
      action :install
    end
  end

end
