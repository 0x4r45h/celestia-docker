FROM arashidos/celestia-app:v0.6.0
RUN  apk add --no-cache git curl jq
COPY  custom-entrypoint.sh /opt/custom-entrypoint.sh
COPY  helpers.sh /opt/helpers.sh
RUN chmod u+x /opt/custom-entrypoint.sh
RUN chmod u+x /opt/helpers.sh
# p2p, rpc and prometheus port
EXPOSE 26656 26657 1317 9090
ENTRYPOINT ["/opt/custom-entrypoint.sh"]
CMD ["start"]