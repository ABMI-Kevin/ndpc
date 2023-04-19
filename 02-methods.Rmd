# Methods

## Selecting a recorder

Consider selecting an affordable, readily available, and user-friendly autonomous recording unit (ARU) or handheld recording device. Here are some recommended options:

- [Zoom H2N]() are a handheld portable recorder with multiple built-in microphones. It is affordable, lightweight, and easy to use for an introductory user.
  + [H2N Equipment Setup](#h2n-equipment-setup)
  + [H2N Survey Deployment](#h2n-survey-deployment)
- [Wildlife Acoustics SM4]() is a weatherproof, mountable recorder that requires external microphones and offers advanced recording features and durability but comes at a higher price.
  + [SM4 Equipment Setup](#sm4-equipment-setup)
  + [SM4 Survey Deployment](#h2n-survey-deployment)
    
## Equipment and Settings Preparation

Calibration and testing of ARUs prior to conducting a survey is essential for high-quality acoustic data.

### H2N Equipment Setup

- Update firmware to the most recent version (3.0).
- Gather USB cables, SD cards, batteries, windsock, and tripod.
- Follow technical setup steps for Zoom H2N, including adjusting date/time settings, battery power, memory card space, and recording settings.


- Turn on the device using the POWER switch. 
- Press the MENU button, toggle the PLAY button up/down and then press down to select SYSTEM. 
- Select DATE/TIME. 
- Use the PLAY button to select and modify the year, day, month, and time settings as needed. 
- When all settings are correct, select OK and press the PLAY button to exit. 
- Ensure that FILE NAME (under REC settings) is set to DATE so that individual files will be named by the date/time of the start of recording). Do not use DEFAULT. 
- Ensure the recorder has sufficient battery power to record all counts (and pack at least 2 spare AA batteries). 
- Ensure that there is a memory-card inserted with sufficient space (the bottom-right corner of the unit’s screen indicates the remaining time on the SD card). 
- Ensure the recorder uses the following settings:
  + 2CH selected on channel selector dial
  + MIC GAIN set to 10 (maximum)
  + SURROUND is set to S±0 (this is really easy to change by accident, because it is changed by moving the PLAY lever while in RECORD mode)
  + REC FORMAT is set at WAV (when you turn on the recorder, the REC format is displayed on the lower left [e.g., 44.1/16]– if it doesn’t match, go to MENU to change it under REC settings)
  + Use 44.1kHz/16 bit (there are other wav settings that would also work but use a little or a lot more memory). Do not use MP3
  + AUTO REC is OFF
  + LO CUT is ON (may be useful to reduce impacts of wind or traffic noise)
  + COMP/LIMITER is OFF
  + AUTO GAIN is off
  
MS Side Level
0 (120 degrees)
Input Setting
Plug-in Power
Off

### SM4 Equipment Setup

SM4 STUFF HERE

## Conducting the Survey

- Arrive at survey location and follow safety instructions outlined by the designated point count protocol.
- Set up the recorder at a fixed location, keeping it at a minimum distance of 5 meters away from the observer to minimize observer sounds, but no more than 20 meters away to minimize error. A tripod or stable surface is recommended to support the ARU; do not place the recorder on or near a vehicle as it will pick up vibrations that could mask species detections. Placing the recorder to the rear of the vehicle can also minimise the sounds made from a vehicle engine (e.g. car, truck, quad, etc.) after it is shut off.
- Turn on the unit and speak the designated voice note. Move away from the recorder to begin the count and say "START"
- At the end of the count, speak STOP.
- Turn off the recorder and move to the next location. Repeat steps as necessary to conduct more surveys along a route

### H2N Survey Deployment

- Initiate the survey by pressing the RECORD button on the recorder.
- Speak a clear message into the recorder to serve as the voicestamp, including observer name, location (spatial coordinates or identifier), and optional date and time stamp.
- Move 5-20 meters away from the recorder to reduce observer noise.
- Say "START" to indicate the end of the speech-to-text recording and move away from the recorder

### SM4 Survey Deployment


### Voice Notes

Voice notes serve as an effective tool for capturing spatial and temporal information. It is essential that users follow a specific speaking order to ensure accuracy and consistency in their voice notes. 

- Observer's name
- Location name
- Date and time

If the location is off-road or in a new area, it is also necessary to provide latitude and longitude coordinates. Following this speaking order will allow for easy organization and standardization of data during the file-naming process.

To create a standard filename format after processing the voice note through speech-to-text recognition, the location name should be written first, followed by the date and time in a specific format. The format for the date should be in YYYYMMDD (year, month, day), and the time should be in HHMMSS (hour, minute, second) format. The resulting filename format will be in the following manner: LOCATION_YYYYMMDD_HHMMSS.wav.

By adhering to the specific speaking order, researchers and data collectors can maintain a standardized approach to data collection, organization, and analysis. This approach will lead to increased efficiency and ease in interpreting and utilizing the collected data for various purposes.

### Survey Length Adjustment

Surveys may occur along roadsides or near areas of loud anthropogenic noise. In order to optimize species detections in the detection radius of the ARU, survey time can be extended by 1 minute per traffic event up to maximum survey length time of 10 minutes. It’s recommended to keep a stopwatch or phone timer set to the length of the survey interval, and the maximum survey interval so you don’t have to keep track of the traffic events specifically but rather the time you can survey for. Geophonic events are similar. 

If it becomes too windy or rainy to continue the survey, i.e. if geophonic events last for >10 minutes during the survey, the media will be considered “Bad Weather”. However, surveys can be extended for 1 minute at a time for intermittent periods of rain or wind.

### Important Notes

- Do not to speak during the survey to limit erroneous speech errors picked up by the speech-to-text recognizer

## Data submission

Cirrus is a server administered by the University of Alberta SRIT. The Bioacoustic Unit and its collaborators use Cirrus to house and standardize their acoustic data sets for redundancy or permanent storage on a cost-recovery basis. Cirrus contains a variety of different types of data but a large majority of the volume is currently being occupied with environmental sensor data i.e. acoustic recordings and remote camera images. 

Raw recordings uploaded to Cirrus via an FTP in order to standardize them before they are processed in WildTrax.

### How do I connect to Cirrus?

Download an FTP client like [Filezilla](). Enter the following credentials:

**Host**: upload.wildtrax.ca or sftp://upload.wildtrax.ca
**User**: eccc
**Password**: w0rdb1rd
**Port**: 22



### Do my data follow the standard file name convention?
