# libSQL Server (sqld) for Railway.
# Official image, pinned by version and digest. Bump both together and add a CHANGELOG.md entry.
FROM ghcr.io/tursodatabase/libsql-server:v0.24.33@sha256:f8ca0134cdded747793888e48591aece07647d9d598d3ac229aabfa93159ca88

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

# The upstream wrapper (run by our start script) fixes the volume's ownership,
# then drops to the unprivileged sqld user.
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["/bin/sqld"]
