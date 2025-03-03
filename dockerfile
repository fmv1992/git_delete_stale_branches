# Install a recent version of `gawk`. --- {{{
# This is necessary because of
# <https://github.com/fmv1992/git_delete_stale_branches/blob/0562cd3440413effc9f84bd07af87696b3a290c1/git_delete_stale_branches/usr/local/lib/git_delete_stale_branches/git_delete_stale_branches#L32>,
# i.e. `gawk` uses the `--csv` option that is not available on `ubuntu` images
# as of 2025-03-02.
#
# This probably can be deleted in a few years from today.

FROM ubuntu@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS gawk_builder
RUN apt-get update && apt-get install --yes \
        autoconf \
        automake \
        bison \
        build-essential \
        gcc \
        git \
        libtool \
        m4 \
        make \
        mawk \
        parallel \
        perl \
        texinfo
RUN cd /tmp \
        && git clone --recurse-submodules --jobs 8 -- https://git.savannah.gnu.org/git/gawk.git
RUN cd /tmp/gawk \
        && git checkout e405f5487b66eadd24d303a27c312f16bcca2ca4 \
        && git reset --hard e405f5487b66eadd24d303a27c312f16bcca2ca4 \
        && { git ls -z | parallel --verbose --max-args 10 --null -- 'sed --in-place --regexp-extended '"'"'s/^AC_PREREQ.*/# \0/g'"'"' ' || true ; } \
        && sh ./configure \
        && make \
        && make install \
        && gawk --version \
        && cd / \
        && rm -rf /tmp/gawk

# --- }}}

FROM ubuntu@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PROJECT
run set -x ; [[ -n $PROJECT ]]
ENV PROJECT $PROJECT

ARG DEBIAN_FRONTEND=noninteractive

# We install `gawk` just to satisfy `checkinstall`.
RUN apt-get update && apt-get install --yes \
        gawk \
        git \
        python3 \
        recutils \
        sudo

# We overwrite the original gawk here.
COPY --from=gawk_builder /usr/local/bin/gawk /usr/local/bin/gawk

ADD https://github.com/fmv1992/shell_argument_parsing_file/releases/download/v0.0.1/shell-argument-parsing-file_0.0.1-1_amd64.deb /tmp/1.deb
RUN dpkg -i /tmp/1.deb

ARG USER_UID
RUN set -x ; [[ -n $USER_UID ]]
ARG USER_GID
RUN set -x ; [[ -n $USER_GID ]]
RUN groupadd --system --gid $USER_GID ubuntu_user \
    && useradd --no-log-init --create-home --system --gid $USER_GID ubuntu_user \
    && echo ubuntu_user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu_user \
    && chmod 0440 /etc/sudoers.d/ubuntu_user
USER ubuntu_user
ENV HOME /home/ubuntu_user
RUN mkdir -p $HOME
WORKDIR $HOME/${PROJECT}

COPY --chown=ubuntu_user:ubuntu_user ./ ${HOME}/${PROJECT}
COPY --chown=ubuntu_user:ubuntu_user ./output/deb/ /opt/deb

CMD ["bash"]
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

ARG GIT_COMMIT
RUN set -x ; [[ -n $GIT_COMMIT ]]

ARG BUILD_DATE
RUN set -x ; [[ -n $BUILD_DATE ]]

# ✂ --------------------------------------------------
# Inject as envvars so they're accessible inside
ENV IMAGE_NAME="$IMAGE_NAME" \
    BUILD_DATE="$BUILD_DATE" \
    BUILD_URL="$BUILD_URL" \
    BUILD_NUMBER="$BUILD_NUMBER" \
    GIT_COMMIT="$GIT_COMMIT" \
    GIT_COMMIT_DATE="$GIT_COMMIT_DATE"

# Metadata
LABEL \
    org.opencontainers.image.title="$IMAGE_NAME"
# -------------------------------------------------- ✂

# vim: set filetype=dockerfile fileformat=unix nowrap spell spelllang=en,cdenglish01:
