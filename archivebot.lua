dofile("wget_behaviors/acceptance_heuristics.lua")
dofile("wget_behaviors/url_counting.lua")

wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
  -- Second-guess wget's host-spanning restrictions.
  if not verdict and reason == 'DIFFERENT_HOST' then
    -- Is the parent a www.example.com and the child an example.com, or vice
    -- versa?
    if is_www_to_bare(parent, urlpos.url) then
      -- OK, grab it after all.
      return true
    end

    -- Is this a URL of a non-hyperlinked page requisite?
    if is_page_requisite(urlpos) then
      -- Yeah, grab these too.
      return true
    end
  end

  -- Return the original verdict.
  return verdict
end

wget.callbacks.httploop_result = function(url, err, http_stat)
  categorize_statcode(http_stat.statcode)

  if count % 50 == 0 then
    print_summary()
    io.stdout:write("\n")
    io.stdout:flush()
  end

  return wget.actions.NOTHING
end

wget.callbacks.finish = function(start_time, end_time, wall_time, numurls, total_downloaded_bytes, total_download_time)
  print_summary()
  io.stdout:write("  ")
  io.stdout:write(total_downloaded_bytes.." bytes.")
  io.stdout:write("\n")
  io.stdout:flush()
end

-- vim:ts=2:sw=2:et:tw=78