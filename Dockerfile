FROM ubuntu:15.10

# Install dependencies
RUN echo "deb http://archive.ubuntu.com/ubuntu/ vivid universe" | tee -a "/etc/apt/sources.list"
RUN apt-get update && apt-get install -y \
	mplayer \
	imagemagick \
	tesseract-ocr \
	wget \
	zip \
&& rm -rf /var/lib/apt/lists/*

## ADD AN ENTRYPOINT STANZA

# Copy the video-processing script into the container
## THIS IS NOT WORKING
COPY process-video.sh /home/ubuntu/
COPY manager.sh /home/ubuntu/
