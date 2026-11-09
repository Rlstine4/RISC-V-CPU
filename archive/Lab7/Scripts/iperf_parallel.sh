#! /usr/local/bin/bash

echo "Starting"
ssh n0.Lab7-ABD.USCEE533 -f /usr/local/etc/emulab/emulab-iperf -c n1 -u -p 7002 -l 512B -t 30 --bandwidth 1000M &
ssh n1.Lab7-ABD.USCEE533 -f /usr/local/etc/emulab/emulab-iperf -c n2 -u -p 7003 -l 512B -t 30 --bandwidth 1000M &
ssh n2.Lab7-ABD.USCEE533 -f /usr/local/etc/emulab/emulab-iperf -c n3 -u -p 7004 -l 512B -t 30 --bandwidth 1000M &
ssh n3.Lab7-ABD.USCEE533 -f /usr/local/etc/emulab/emulab-iperf -c n0 -u -p 7001 -l 512B -t 30 --bandwidth 1000M &


