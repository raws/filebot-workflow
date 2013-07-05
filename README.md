### FileBot workflow

This is my [FileBot](http://filebot.net) workflow which automatically identifies, renames, organizes and hard links completed Transmission downloads. It uses a modified version of [rednoah's Automated Media Center](http://www.filebot.net/forums/viewtopic.php?f=4&t=215) script.

Files are renamed and organized like this:

* **Movie:** `/volume1/movies/Independence Day (1996)/Independence Day (1996).mkv`
* **TV episode:** `/volume1/tv/Police Squad!/Season 1/Police Squad! - S01E01 - A Substantial Gift.mkv`

The originals remain unchanged in the torrents folder for continued seeding, but can be deleted at will, thanks to the hard links.

Since FileBot requires Java 7 for its `--action hardlink` option, and Java 7 isn't yet available for my x86 Synology DS1511+, I have modified the script to shell out directly to the `ln` utility to create hard links.

### Configuring Transmission

To make Transmission run the script after a torrent completes, edit Transmission's `settings.json` like so:

```json
{
  "script-torrent-done-enabled": true,
  "script-torrent-done-filename": "path/to/transmission-post-process.sh"
}
```

Other torrent clients probably have similar configuration options.

### Running manually

To run the script manually and organize files at any path, you can use something like the following on BusyBox embedded Linux with Ruby 1.9, like I have on my Synology NAS:

```ruby
path = $_.strip.force_encoding("utf-8")

command = [
  'env',
  "TR_TORRENT_DIR=#{File.dirname(path).shellescape}",
  "TR_TORRENT_NAME=#{File.basename(path).shellescape}",
  '/volume1/@appstore/filebot-workflow/transmission-post-process.sh'
].join(' ')

puts command
system command
```

```bash
find /volume1/torrents/Seeding -mindepth 1 -maxdepth 1 -print | ruby -rshellwords -n transmission-post-process.rb
```

(The above is pretty hacked together and should be rewritten without shelling out through Ruby.)

### Git workflow

When rednoah updates his Automated Media Center script, commit his changes to `amc.groovy` in the `rednoah` branch. Then merge those changes into `master`.
