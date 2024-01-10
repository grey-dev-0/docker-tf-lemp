FROM kernel:latest
COPY resources/mutagen/mutagen /usr/bin/
COPY resources/mutagen/init /root/
RUN chmod +x /usr/bin/mutagen /root/init
ENTRYPOINT /root/init