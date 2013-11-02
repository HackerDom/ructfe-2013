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
  end

  def can_delete?(path)
    @log.debug("can_delete? (#{path})")
  end

  def can_mkdir?(path)
    @log.debug("can_mkdir? (#{path})")
    return true
  end

  def can_write?(path)
    @log.debug("can_write? (#{path})")
    return true
  end

  def contents(path)
    @log.debug("contents (#{path})")

    files = []
    level = path == "/" ? 1 : 1 + path.count("/")
    like  = path == "/" ? "/%" : "#{path}/%"

    @pg.exec(
      "SELECT path " +
      "FROM files " +
      "WHERE path LIKE '#{like}' AND level = #{level}"
    ).each_row do |row|
      name = row[0].split("/")
      files.push(name[-1])
    end

    return files
  end

  def size(path)
    @log.debug("size (#{path})")

    size = @pg.exec(
      "SELECT size " +
      "FROM files " +
      "WHERE path = '#{path}'"
    ).getvalue(0, 0)

    return size.to_i
  end

  def file?(path)
    @log.debug("file? (#{path})")

    row = @pg.exec(
      "SELECT type " +
      "FROM files " +
      "WHERE path = '#{path}'"
    )

    if (row.ntuples > 0)
      return row.getvalue(0, 0) == '-'
    else
      return false
    end
  end

  def directory?(path)
    @log.debug("directory? (#{path})")

    return !file?(path)
  end

  def mkdir(path)
    @log.debug("mkdir (#{path})")

    level = path.count("/")

    @pg.exec(
      "INSERT INTO files " +
      "(path, level, type, size, mode, atime, mtime, ctime) VALUES " +
      "('#{path}', #{level}, 'd', 0, 644, now(), now(), now())"
    )
  end

  def read_file(path)
    @log.debug("read_file (#{path})")

    row = @pg.exec_params("SELECT data FROM chunks WHERE path = '#{path}'", [], 1)

    return row.getvalue(0, 0)
  end

  def write_to(path, str)
    @log.debug("write_to (#{path}) '#{str}'")

    level = path.count("/")
    size  = str.length

    row = @pg.exec("SELECT path FROM files WHERE path = '#{path}'")
    if (row.ntuples > 0)
      @pg.exec(
        "UPDATE files " +
        "SET (path, level, type, size, mode, atime, mtime, ctime) = " +
        "('#{path}', #{level}, '-', #{size}, 644, now(), now(), now()) " +
        "WHERE path = '#{path}'"
      )
      @pg.exec(
        "UPDATE chunks " +
        "SET (data) = ('#{str}') " +
        "WHERE path = '#{path}'"
      )
    else
      @pg.exec(
        "INSERT INTO files " +
        "(path, level, type, size, mode, atime, mtime, ctime) VALUES " +
        "('#{path}', #{level}, '-', #{size}, 644, now(), now(), now())"
      )
      @pg.exec(
        "INSERT INTO chunks " +
        "(path, data) VALUES ('#{path}', '#{str}')"
      )
    end

  end

end

FuseFS.start(PFS.new, *ARGV)
