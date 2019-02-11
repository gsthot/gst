#!/bin/bash
echo -e "\033[35m 正在停止浏览器前端服务...\033[0m"
pkill ng$
sleep 0.5

echo -e "\033[35m 正在停止浏览器后台服务...\033[0m"
systemctl stop nginx

sleep 1s
rm -f /work/wwwlogs/*
rm -f /work/gst_install/tracker/trackerapi/var/logs/*
rm -rf /work/gst_install/tracker/trackerapi/var/cache/dev/*
rm -rf /work/gst_install/tracker/trackerapi/var/cache/prod/*
rm -f /work/gst_install/nodgst/data/bpnode.log
echo "正在停止区块nodgst服务..."
pkill nodgst
sleep 0.5
echo "正在停止钱包kgstd服务..."
pkill kgstd
sleep 3s

echo -e "\033[31m----------------------------------------------------------------------\033[0m"
echo -e "\033[35m 正在清除区块数据...\033[0m"
rm -rf /work/gst_install/nodgst/data/*
rm -f /work/gst_install/wallet/wallet.log

ret=$(ps -ef |grep mongod|grep -v grep|wc -l)
if [ $ret -lt 2 ];then
   echo "the mongod service is ERR"
   systemctl start mongod
fi
mongo 127.0.0.1:27017/gstdb  --eval 'db.dropDatabase();'
echo -e "\033[31m----------------------------------------------------------------------\033[0m"

chown -R mongod:mongod /work/gst_install/mongo
chmod -R 777 /work/gst_install/mongo
sleep 2s

cd /work/gst_install
 echo -e "\033[32m 正在启动区块nodgst服务...\033[0m"
nohup /work/gst_install/gst/build/bin/nodgst --data-dir=/work/gst_install/nodgst/data \
--config-dir=/work/gst_install/nodgst/config \
--genesis-json=/work/gst_install/nodgst/config/genesis.json  --max-transaction-time=3000 > /work/gst_install/nodgst/data/bpnode.log 2>&1 &

echo -e "\033[32m 正在启动钱包服务...\033[0m"
nohup /work/gst_install/gst/build/bin/kgstd --data-dir=/work/gst_install/wallet \
--config-dir=/work/gst_install/wallet > /work/gst_install/wallet/wallet.log 2>&1 &

alias clgst='clgst -u http://127.0.0.1:8888 --wallet-url http://127.0.0.1:8900'

echo -e "\033[32m nodeo service start...\033[0m"

echo "PW5Ka7m2J2wLAhA3wbJPQ9XhFMc5KVLVE2qYTETr6cEvwqyrTGJAw" | clgst wallet unlock
clgst wallet list
clgst wallet import --private-key 5JfxbuzqBVTc1SsHQ9RFY4aExuNtGZapGyCe6uapdZAPwKcBAAz
clgst wallet import --private-key 5KarHtfxsJY9Ei8kmZpFo5GeA3rEWmC6Qe9UubkKfvLchE5MbtE
clgst wallet import --private-key 5JF6qVx2otj5d6TqzGxpQQgoULj9r2GCZH5NPw16PwPS3BGFFEv
clgst wallet import --private-key 5K4SqTVrWVauwM6je8pWxi9aAwoqtwnByqZcmZnVSaAc666793X
sleep 3s

echo "钱包中的私钥列表..."
echo "PW5Ka7m2J2wLAhA3wbJPQ9XhFMc5KVLVE2qYTETr6cEvwqyrTGJAw" | clgst wallet private_keys

STALE_NOD=$(netstat -ln|grep -o 8888)
if [ "$STALE_NOD" == "" ]; then
      cat /work/gst_install/nodgst/data/bpnode.log | grep -B 1 ^error

      nohup /work/gst_install/gst/build/bin/nodgst --data-dir=/work/gst_install/nodgst/data \
	--config-dir=/work/gst_install/nodgst/config --max-transaction-time=3000 > /work/gst_install/nodgst/data/bpnode.log 2>&1 &
	sleep 2s
fi

echo "公钥 GST8MfTEt* 对应的帐户列表..."
clgst get accounts GST8MfTEtHsMU1AGL4LYbYx3eiU9iVK3K6WXUEoJHkieVAbj9gHDz

echo "gstio account info:"
clgst get account gstio

echo "account gstio currency balance:"
clgst get currency balance gstio.token gstio GST

echo "GST currency stats:"
clgst get currency stats gstio.token GST

echo "account bp1 info:"
clgst get account bp1
sleep 1s

echo "account voter1 info:"
clgst get account voter2
sleep 1s

echo "account bp1 info:"
clgst get account bp1
sleep 1s

echo "当前区块信息..."
clgst get info

sleep 1s

#echo "正在启动浏览器后台服务..."
#systemctl start nginx

#echo "正在启动浏览器前端服务..."
#cd /work/gst_install/tracker/frontend
#nohup ng serve --host 0.0.0.0 --port 4200 >/dev/null 2>&1 &
#sleep 3s

#systemctl status nginx
ps -al

netstat -lntp

echo "done..."