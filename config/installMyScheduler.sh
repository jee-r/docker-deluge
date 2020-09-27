!#/bin/sh

git clone https://github.com/h3llrais3r/deluge-myscheduler.git /tmp/MyScheduler 
cd /tmp/MyScheduler
python3 setup.py bdist_egg
cp /tmp/*.egg /config/plugins/
echo "You need to run 'chmod -R UID:GID /config/plugin/' egg file is owned by root !"
