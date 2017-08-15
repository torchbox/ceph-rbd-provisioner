FROM centos:7 AS build

RUN yum -y install git

# Install go
RUN curl -sSL https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz | gzip -dc | tar xf - -C /usr/local

ENV PATH /usr/local/go/bin:/usr/local/bin:/bin:/usr/bin
ENV GOPATH /usr/src/go

# Add source
WORKDIR /usr/src/go/src/github.com/kubernetes-incubator/external-storage
RUN git clone https://github.com/kubernetes-incubator/external-storage .

# Build
RUN cd ceph/rbd && env CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o rbd-provisioner ./cmd/rbd-provisioner

FROM centos:7

RUN rpm -Uvh https://download.ceph.com/rpm-luminous/el7/noarch/ceph-release-1-1.el7.noarch.rpm
RUN yum install -y epel-release
RUN yum install -y ceph-common
COPY --from=build /usr/src/go/src/github.com/kubernetes-incubator/external-storage/ceph/rbd/rbd-provisioner /usr/local/bin/rbd-provisioner
ENTRYPOINT ["/usr/local/bin/rbd-provisioner"]
