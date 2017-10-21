# rpi-ffmpeg
This docker image compiles FFmpeg for the Raspberry Pi 3 with various plugins.
Pre-build step compiles the fantastic [VidStab](https://github.com/georgmartius/vid.stab) library.

# Included plugins:
* libvidstab
* libx264
* libx265

# Example usage
### Batch stabilize videos to x265 and export side-by-side comparison
```
docker container run -v /tmp/videos:/tmp --rm ffmpeg:latest bash -c 'cd /tmp/ && for f in *.MP4; do ffmpeg -i "$f" -vf vidstabdetect=shakiness=10:accuracy=15 -f null -; ffmpeg -i "$f" -vf vidstabtransform=smoothing=30:input="transforms.trf",scale=in_range=auto:out_range=full -c:v libx265 -preset slow -crf 18 -c:a flac -compression_level 12 "${f%}_stabilized.mkv"; ffmpeg -i "$f" -i "${f%}_stabilized.mkv" -filter_complex "[0:v]setpts=PTS-STARTPTS, pad=iw*2:ih[bg]; [1:v]setpts=PTS-STARTPTS[fg]; [bg][fg]overlay=w" "${f%}_side_by_side.mkv"; done'
```

# FAQ
* Q: But will I have enough memory to encode anything on the Pi?
* A: May your /swap be mighty and your RAM overfloweth.

