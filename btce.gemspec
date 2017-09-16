# -*- coding: utf-8 -*-
# -*- mode: Ruby -*-

# Copyright © 2013-2016, Christopher Mark Gore,
# Soli Deo Gloria,
# All rights reserved.
#
# 2317 South River Road, Saint Charles, Missouri 63303 USA.
# Web: http://cgore.com
# Email: cgore@cgore.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#   * Neither the name of Christopher Mark Gore nor the names of other
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

Gem::Specification.new do |s|
  s.name = 'btce'
  s.version = '0.6.0'
  s.date = '2017-09-16'
  s.summary = "A simple library to interface with the API for wex.nz in Ruby."
  s.description = "A simple library to interface with the API for wex.nz in Ruby."
  s.authors = ['Auston Bunsen',
               'Christoph Bünte',
               'Charley David',
               'Davide Di Cillo',
               'Edward Funger',
               'Christopher Mark Gore',
               'Stephan Kaag',
               'Sami Laine',
               'Selvam Palanimalai',
               'Kevin Pheasey',
               'Jaime Quint',
               'Panupan Sriautharawong',
               'Michaël Witrant',
               'Ramón Martínez']
  s.email = 'cgore@cgore.com'
  s.files = `git ls-files lib/`.split($/)
  s.homepage = 'https://github.com/cgore/ruby-btce'
  s.required_ruby_version = ">= 2.2.2"
  s.add_dependency 'monkey-patch', "~> 0.1.0"
end
