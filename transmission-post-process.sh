# /opt/bin/bash
# transmission-post-process.sh
#
# Rename and hard link a file using FileBot.
#
# You can set environment variables (such as with Transmission):
#
#   env TR_TORRENT_DIR=/volume1/torrents/Seeding TR_TORRENT_NAME=Archer.S01E01.uGlY.nAmE.mkv \
#     transmission-post-process.sh
#
# Or you can pass a complete path to the target file or directory:
#
#   transmission-post-process.sh /volume1/torrents/Seeding/Archer.S01E01.uGlY.nAmE.mkv
#
# The TR_TORRENT_NAME (or complete path) may be a file or a directory. In the case of a directory,
# the folder is recursively searched and the most likely candidate media file is chosen.

if [[ ( -z "$TR_TORRENT_DIR" || -z "$TR_TORRENT_NAME" ) && ( -n "$1" ) ]]; then
  TR_TORRENT_DIR=`dirname $1`
  TR_TORRENT_NAME=`basename $1`
fi

if [[ -z "$TR_TORRENT_DIR" || -z "$TR_TORRENT_NAME" ]]; then
  echo 'transmission-post-process.sh: set $TR_TORRENT_{DIR,NAME} or supply a path as an argument' >&2
  exit 1
fi

/usr/bin/filebot  -script "/volume1/@appstore/filebot-workflow/amc.groovy" \
                 --output "/volume1" \
                 --log-file "/volume1/@appstore/filebot-workflow/filebot.log" \
                 --conflict override \
                  -non-strict \
                 --def music=n \
                       artwork=n \
                       "ut_dir=$TR_TORRENT_DIR/$TR_TORRENT_NAME" \
                       "ut_kind=multi" \
                       "ut_title=$TR_TORRENT_NAME" \
                       "seriesFormat=tv/{n.replaceTrailingBrackets()}/Season {s}/{n.replaceTrailingBrackets()} - {s00e00} - {t}" \
                       "movieFormat=movies/{n.replaceTrailingBrackets()} ({y})/{n.replaceTrailingBrackets()} ({y})"
