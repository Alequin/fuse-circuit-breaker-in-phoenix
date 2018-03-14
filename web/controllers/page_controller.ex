defmodule FusePlay.PageController do
  use FusePlay.Web, :controller

  @fuse_name :my_fuse

  def index(conn, _params) do
    check_install_fuse()

    case :fuse.ask(@fuse_name, fuse_context()) do
      :ok ->
        # melting the fuse adds to the error count
        :fuse.melt(@fuse_name)
        text(conn, "fuse ok, metling it")

      :blown ->
        text(conn, "fuse blown")
    end
  end

  defp check_install_fuse() do
    case :fuse.ask(@fuse_name, fuse_context()) do
      {:error, :not_found} ->
        install_fuse()

      _ ->
        :ok
    end
  end

  defp install_fuse() do
    strategy = standard_strategy()
    refresh = {:reset, 5000}
    opts = {strategy, refresh}
    :fuse.install(@fuse_name, opts)
  end

  # Strategy denotes what kind of fuse we have.
  #
  # Standard fuses, {standard, MaxR, MaxT}. These are fuses which
  # tolerate MaxR melt attempts in a MaxT window, before they break down.
  #
  # Fault injection fuses, {fault_injection, Rate, MaxR, MaxT}. This
  # fuse type sets up a fault injection scheme where the fuse fails
  # at rate Rate, an floating point value between 0.0–1.0. If you
  # enter, say 1 / 500 then roughly every 500th request will se a
  # blown fuse, even if the fuse is okay. This can be used to add
  # noise to the system and verify that calling systems support the
  # failure modes appropriately. The values MaxR and MaxT works as
  # in a standard fuse.

  defp standard_strategy() do
    # attempts always seem to be +1 of this value
    attemps_to_make = 5
    time_span_of_errors = 10000
    {:standard, attemps_to_make, time_span_of_errors}
  end

  defp fault_injection_strategy() do
    # fails on avaerage 50% of the time (example only)
    fail_rate = 1 / 2
    attemps_to_make = 50
    time_span_of_errors = 10000
    {:fault_injection, fail_rate, attemps_to_make, time_span_of_errors}
  end

  # sync - call the fuse synchronously. This is the safe way where each
  # call is factored through the fuse server. It has no known race conditions.
  #
  # async_dirty - A fast call path, which circumvents the single fuse_server process.
  # It is much faster, but has been known to provide rare races in which
  # parallel processes might observe the wrong values. In other words,
  # with Context = async_dirty the calls are not linearizible.
  defp fuse_context() do
    :sync
    # :async_dirty
  end
end
