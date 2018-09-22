## On node ceph-adm as cephadm
~~~
mkdir cluster
cd cluster/

ceph-deploy new ceph-mon

ceph-deploy install \
ceph-adm \
ceph-osd1 \
ceph-osd2 \
ceph-osd3 \
ceph-mon

ceph-deploy mon create-initial

ceph-deploy gatherkeys ceph-mon

ceph-deploy disk list \
ceph-osd1 \
ceph-osd2 \
ceph-osd3

ceph-deploy disk zap \
ceph-osd1:/dev/sdb \
ceph-osd2:/dev/sdb \
ceph-osd3:/dev/sdb

ceph-deploy osd prepare \
ceph-osd1:/dev/sdb \
ceph-osd2:/dev/sdb \
ceph-osd3:/dev/sdb

ceph-deploy osd activate \
ceph-osd1:/dev/sdb \
ceph-osd2:/dev/sdb \
ceph-osd3:/dev/sdb

ceph-deploy disk list \
ceph-osd1 \
ceph-osd2 \
ceph-osd3

ceph-deploy admin \
ceph-adm \
ceph-mon \
ceph-osd1 \
ceph-osd2 \
ceph-osd3

~~~

### On All Nodes
~~~
sudo chmod 644 /etc/ceph/ceph.client.admin.keyring
(We can use ssh <node> sudo chmod 644 /etc/ceph/ceph.client.admin.keyring)
~~~


### On ceph-mon
~~~
sudo ceph health

sudo ceph -s
ceph
>health

~~~

### Testing
~~~
echo "This a TEST" >testfile.txt
ceph osd pool create mytest 8
rados put testfile $(pwd)/testfile.txt --pool=mytest
rados -p mytest ls
ceph osd map mytest testfile

~~~
