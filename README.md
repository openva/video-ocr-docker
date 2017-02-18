# video-ocr-docker
A Dockerized version of Richmond Sunlight's video OCR process.

## Instructions

Replace the VPC ID with your own VPC ID, and the EC2 Zone with your own Zone. And the video file with the one that you need.

```
docker-machine create --driver amazonec2 --amazonec2-vpc-id vpc-2a495e48 --amazonec2-zone "c" video-processor
eval $(docker-machine env video-processor)
docker build -t video-processor .
docker-machine scp manager.sh video-processor:.
docker-machine scp process-video.sh video-processor:.
docker run video-processor wget -q https://www.richmondsunlight.com/video/senate/floor/20170216.mp4
docker run video-processor /bin/bash '/home/ubuntu/process-video.sh 20170216 senate'
docker-machine stop video-processor
```
