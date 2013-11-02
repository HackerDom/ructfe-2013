#!/usr/bin/ruby-1.9

require 'logger'
require 'pg'
require 'rfusefs'

class PFS < FuseFS::FuseDir

  def initialize
    @log = Logger.new(STDERR)
    @pg  = PG.connect(
      hostaddr: '127.0.0.1',
      port:      5432,
      dbname:   'pfs',
      user:     'pfs',
      password: 'qwer'
    )
    puts @pg.exec('SELECT 13').getvalue(0,0)
  end

  def can_delete?(path)
    @log.debug("can_delete? (#{path})")
  end

  def can_mkdir?(path)
    @log.debug("can_mkdir? (#{path})")
    return false
  end

  def can_write?(path)
    @log.debug("can_write? (#{path})")
    true
  end

  def contents(path)
    @log.debug("contents (#{path})")
    ['hello.txt']
  end

  def size(path)
    @log.debug("size (#{path})")
    read_file(path).size
  end

  def file?(path)
    @log.debug("file? (#{path})")
    path == '/hello.txt'
  end

  def directory?(path)
    @log.debug("directory? (#{path})")
    false
  end

  def read_file(path)
    @log.debug("read_file (#{path})")
    "HW!\n"
  end

  def write_to(path, str)
    @log.debug("write_to (#{path}) '#{str}'")
  end

end

FuseFS.start(PFS.new, *ARGV)
