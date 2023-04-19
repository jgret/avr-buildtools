avrdude -C"$AVR_BUILDTOOLS_BASEDIR/avrdude.conf" -c arduino -p m644p -P$1 -U f:w:$2:i
