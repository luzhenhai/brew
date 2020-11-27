# typed: strict
# frozen_string_literal: true

require "utils/git"
require "utils/popen"

# Extensions to {Pathname} for querying Git repository information.
# @see Utils::Git
# @api private
module GitRepositoryExtension
  extend T::Sig

  sig { returns(T::Boolean) }
  def git?
    join(".git").exist?
  end

  # Gets the URL of the Git origin remote.
  sig { returns(T.nilable(String)) }
  def git_origin
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "config", "--get", "remote.origin.url", chdir: self).chomp.presence
  end

  # Sets the URL of the Git origin remote.
  sig { params(origin: String).returns(T.nilable(T::Boolean)) }
  def git_origin=(origin)
    return unless git? && Utils::Git.available?

    safe_system "git", "remote", "set-url", "origin", origin, chdir: self
  end

  # Gets the full commit hash of the HEAD commit.
  sig { returns(T.nilable(String)) }
  def git_head
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "rev-parse", "--verify", "-q", "HEAD", chdir: self).chomp.presence
  end

  # Gets a short commit hash of the HEAD commit.
  sig { returns(T.nilable(String)) }
  def git_short_head
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "rev-parse", "--short=4", "--verify", "-q", "HEAD", chdir: self).chomp.presence
  end

  # Gets the relative date of the last commit, e.g. "1 hour ago"
  sig { returns(T.nilable(String)) }
  def git_last_commit
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "show", "-s", "--format=%cr", "HEAD", chdir: self).chomp.presence
  end

  # Gets the name of the currently checked-out branch, or HEAD if the repository is in a detached HEAD state.
  sig { returns(T.nilable(String)) }
  def git_branch
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "rev-parse", "--abbrev-ref", "HEAD", chdir: self).chomp.presence
  end

  # Returns the date of the last commit, in YYYY-MM-DD format.
  sig { returns(T.nilable(String)) }
  def git_last_commit_date
    return unless git? && Utils::Git.available?

    Utils.popen_read("git", "show", "-s", "--format=%cd", "--date=short", "HEAD", chdir: self).chomp.presence
  end
end
