FROM scratch AS ctx

COPY build_files /

FROM ghcr.io/hecknt/archlinux-bootc:latest
COPY system_files /
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /

ENV DRACUT_NO_XATTR=1

# Temporary resolv.conf. We set --dns=none so that /etc/resolv.conf doesn't get mounted into the image.
RUN echo -e 'nameserver 1.1.1.1' > /etc/resolv.conf

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/00-start.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/01-drivers.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/10-dev.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/20-desktop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/21-fonts.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/98-bootc.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=tmpfs,dst=/tmp \
  /ctx/99-cleanup.sh

# Setup a temporary root passwd (1234) for dev purposes
# RUN usermod -p "$(echo "1234" | mkpasswd -s)" root

RUN bootc container lint --no-truncate
