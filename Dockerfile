# Switch this to a multi-stage build once quay.io supports it.
#FROM centos:7 AS build
FROM centos:7

RUN yum -y install git

# Install go
RUN curl -sSL https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz | gzip -dc | tar xf - -C /usr/local

ENV GOPATH /usr/src/go
ENV PATH /usr/local/go/bin:/usr/local/bin:/bin:/usr/bin

# Add source
WORKDIR /usr/src/go/src/github.com/kubernetes-incubator/external-storage
RUN git clone https://github.com/kubernetes-incubator/external-storage .

# Build
RUN set -ex && cd /usr/src/go/src/github.com/kubernetes-incubator/external-storage/ceph/rbd && env CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o rbd-provisioner ./cmd/rbd-provisioner

#FROM centos:7

RUN cp /usr/src/go/src/github.com/kubernetes-incubator/external-storage/ceph/rbd/rbd-provisioner /usr/local/bin/rbd-provisioner

RUN rpm -Uvh https://download.ceph.com/rpm-luminous/el7/noarch/ceph-release-1-1.el7.noarch.rpm
RUN yum install -y epel-release
RUN yum install -y ceph-common
#COPY --from=build /usr/src/go/src/github.com/kubernetes-incubator/external-storage/ceph/rbd/rbd-provisioner /usr/local/bin/rbd-provisioner
RUN rm -rf /usr/src/go /usr/local/go

ENTRYPOINT ["/usr/local/bin/rbd-provisioner"]
