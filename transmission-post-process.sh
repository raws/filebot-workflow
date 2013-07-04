#!/opt/bin/bash
/usr/bin/filebot -script fn:amc \
		   	     --output "/volume1" \
			     --log-file "/volume1/@appstore/transmission/var/filebot.log" \
			     --action hardlink \
			     --conflict override \
			     -non-strict \
			     --def music=n \
			           artwork=n \
			           "ut_dir=$TR_TORRENT_DIR/$TR_TORRENT_NAME" \
			           "ut_kind=multi" \
			           "ut_title=$TR_TORRENT_NAME" \
			           "seriesFormat=tv/{n.replaceTrailingBrackets()}/Season {s}/{n.replaceTrailingBrackets()} - {s00e00} - {t}" \
			           "moviesFormat=movies/{n.replaceTrailingBrackets()} ({y})/{n.replaceTrailingBrackets()} ({y})"
