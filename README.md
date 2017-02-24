# video-ocr-docker
A Dockerized version of Richmond Sunlight's video OCR process.

## Instructions

Replace the VPC ID with your own VPC ID, and the EC2 Zone with your own Zone. And the video file with the one that you need.

```
docker-machine create --driver amazonec2 --amazonec2-vpc-id vpc-2a495e48 --amazonec2-zone "c" video-processor
eval $(docker-machine env video-processor)
docker build -t video-processor .
docker run ubuntu /bin/bash 'cd ~; ./manager.sh https://www.richmondsunlight.com/video/house/floor/20170223.mp4 house'
docker-machine stop video-processor
```
