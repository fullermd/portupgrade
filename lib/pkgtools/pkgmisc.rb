# vim: set sts=2 sw=2 ts=8 et:
#
# Copyright (c) 2001-2004 Akinori MUSHA <knu@iDaemons.org>
# Copyright (c) 2006-2008 Sergey Matveychuk <sem@FreeBSD.org>
# Copyright (c) 2009-2012 Stanislav Sedov <stas@FreeBSD.org>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

class Array
  def qindex(item)
    lower = -1
    upper = size()
    while lower + 1 != upper
      mid = (lower + upper) / 2

      cmp = self[mid] <=> item

      cmp.zero? and return mid

      if cmp < 0
        lower = mid
      else
        upper = mid
      end
    end

    nil
  end

  alias qinclude? qindex
end

def shellwords(line)
  unless line.is_a?(String)
    raise ArgumentError, "Argument must be String class object."
  end
  line = line.sub(/\A\s+/, '')
  words = []
  while line != ''
    field = ''
    loop do
      if line.sub!(/\A"(([^"\\]|\\.)*)"/, '') #"
        snippet = $1
        snippet.gsub!(/\\(.)/, '\1')
      elsif line.starts_with?('"')
        raise ArgumentError, "Unmatched double quote: #{line}"
      elsif line.sub!(/\A'([^']*)'/, '') #'
        snippet = $1
      elsif line.starts_with?("'")
        raise ArgumentError, "Unmatched single quote: #{line}"
      elsif line.sub!(/\A\\(.)/, '')
        snippet = $1
      elsif line.sub!(/\A([^\s\\'"]+)/, '') #'
        snippet = $1
      else
        line.sub!(/\A\s+/, '')
        break
      end
      field.concat(snippet)
    end
    words.push(field)
  end
  words
end

def shelljoin(*args)
  args.collect do |arg|
    if /[*?{}\[\]<>()~&|\\$;\'\`\s]/ =~ arg
      '"' + arg.gsub(/([$\\\"\`])/, "\\\\\\1") + '"'
    else
      arg
    end
  end.join(' ')
end

def init_tmpdir
  if !$tmpdir.nil? && $tmpdir != ""
    return
  end
  maintmpdir = ENV['PKG_TMPDIR'] || ENV['TMPDIR'] || '/var/tmp'
  if !FileTest.directory?(maintmpdir)
    raise "Temporary directory #{maintmpdir} does not exist"
  end

  cmdline = shelljoin("/usr/bin/mktemp", "-d", maintmpdir + "/portupgradeXXXXXXXX")
  pipe = IO.popen(cmdline)
  tmpdir = pipe.gets
  pipe.close
  if $? != 0 || tmpdir.nil? || tmpdir.empty?
    raise "Could not create temporary directory in #{maintmpdir}"
  end
  tmpdir.chomp!

  at_exit do
    begin
      xsystem("rm -r #{tmpdir}")
    rescue
      warning_message "Could not clean up temporary directory: " + $!
    end
  end
  $tmpdir = tmpdir
end
