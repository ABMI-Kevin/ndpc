# This script is a full-serve protocol on how to deal with data from single-visit, digital point counts

# Import libraries
import os, re, pydub
import speech_recognition as sr
import wave
import pandas as pd
import librosa
from datetime import datetime
from thefuzz import fuzz
import numpy as np
from pydub import AudioSegment
from pydub.utils import make_chunks
from datetime import timedelta
import matplotlib.pyplot as plt

# Need to define location for ffmpeg in order to run the converter
pydub.AudioSegment.converter = '/usr/local/bin/ffmpeg'
file_type = ['.WAV','.mp3'] # Modify only Zoom file types (WAV)
pref = ['ABMI','ABMP','.DS_STORE'] # To deal with Riverforks and hidden files
standard = ['.wav'] # Standard wav file
flac = ['.flac']
# Add more exceptions here and handle in loop below

# Choose working directory
my_dir = ''

while True:
    print('This Python script attempts to reformat audio files using the information stored in the voice note. \n'
          'Please choose a root directory that holds your audio files: \n')
    my_dir = input()
    if os.path.exists(my_dir):
        print('Scanning for files ... this may take a moment ... \n')
    else:
        print('Sorry, could not find this directory. \n')
        continue
    break

# Change the timestamps and append the interim LOCATION prefix
for root, dirs, files in os.walk(my_dir):
    for file in files:
        if file.endswith('.WAV'):
            # Zoom file naming to WA standard - use LOCATION as temporary prefix
            try:
                old = os.path.splitext(file)[0]
                new = str('LOCATION_' + datetime.strftime(datetime.strptime(old, '%y%m%d-%H%M%S'), '%Y%m%d_%H%M%S') + '.wav')
                old_type = str(os.path.join(root, old) + '.wav')
                os.rename(old_type, os.path.join(root, new))
                print('Appended location prefix and fixing timestamps for', old)
            except Exception as e0:
                print('Could not read', file, '\n', e0)
        elif file.startswith(tuple(pref)) and file.endswith(tuple(file_type)):
            print('Coming soon \n')
            pass
        else:
            try:
                ok = os.path.splitext(file)[0]
                ok = datetime.strptime(re.search('(?<=_).*', ok).group(), '%Y%m%d_%H%M%S')
                print(file, 'is standard, no changes', '\n')
            except Exception as e1:
                print(file, 'is not supported or is a RiverForks file.')
                pass

# Create the dictionaries
all_files = {}
files_merge = {}
files_match = {}

# Scan the directory again with the updated paths
for path, dirs, files in os.walk(my_dir):
    for file in files:
        if file.endswith('.wav'):
            all_files.update({(os.path.join(path, file)): ''})
            files_merge.update({(os.path.join(path, file)): ''})
        elif file.lower().endswith('.mp3'):
            fp = os.path.join(path, os.path.splitext(os.path.basename(os.path.join(path, file)))[0] + '.wav')
            try:
                sound = pydub.AudioSegment.from_mp3(os.path.join(path, file))
                sound.export(fp, format='wav')
                print('Success for ', file)
                all_files.update({fp: ''})
                files_merge.update({fp: ''})
            except Exception as e2:
                print(e2, file)
        elif file.endswith('.wav') and file.startswith('ABMI'):
            all_files.update({(os.path.join(path, file)): ''})
            files_merge.update({(os.path.join(path, file)): ''})
        else:
            print('Cant add this file to the queue', file)
            pass

# Double check file time duration
for paths in all_files:
    try:
        f = wave.open(paths, 'rb')
        frames = f.getnframes()
        rate = f.getframerate()
        duration = int(frames / float(rate))
        if 60 <= duration <= 1800:
            all_files.update({paths: duration})
        else:
            print('Duration not supported', duration, paths)
    except wave.Error as e:
        print('File could not be read for: ', paths)
    except EOFError as e:
        print('File could not be read for: ', paths)

# Create the dictionary of speech results
all_files = {paths: duration for paths, duration in all_files.items() if duration is not None}

# Speech recognition services - save to RF dictionary
for paths in all_files:
    audio_file = paths
    with sr.AudioFile(audio_file) as source:  # Use the first audio files as the audio source
        audio = sr.Recognizer().record(source, duration = 60)  # Read the first 60 seconds of audio file
        try:
            location = re.search('[^_]*', os.path.basename(paths))
            results = sr.Recognizer().recognize_google(audio, language='en-US', show_all=True)  # Record the tests
            if not results:
                print('No speech in first minute', paths) # Handle errors
                print(AudioSegment.from_file(paths).duration_seconds, paths)
                all_files.update({paths: 'No speech in first minute'})  # Update the dictionaries
                files_match.update({location.group(0): 'No speech in first minute'})
            else:
                all_files.update({paths: results['alternative'][0]['transcript']})  # Update the dictionaries
                files_match.update({location.group(0): results['alternative'][0]['transcript']})
                print('Speech extracted for', os.path.basename(paths))
        except sr.UnknownValueError:
            print('Could not understand the audio from ' + os.path.basename(paths) + ' or it is not a test recording')
        except sr.RequestError as e:
            print('Could not request results from Google Speech Recognition Service; {0}'.format(e) + ' or recording length is too long')

# Import the sitelist
my_file = ''
while True:
    print('')
    print('Choose how you want to match the voice note? \n',
          'By location name (enter: name), \n'
          'By spatial coordinates (spat), \n'
          'By date and time (dttm), \n'
          'By tone (tone), \n'
          'Or by none - this implies the location name is correct and that youre just looking for the start times \n')
    my_file = input()
    if (my_file == str('spat')) or (my_file == str('dttm')):
        print('Specify a filepath to use to match spatial coordinates: ')
        input_file = input()
        spat_list = pd.read_csv(input_file,delimiter=',',index_col=False)
        spat_list['spats_lat'] = spat_list['latitude'].apply(lambda x: f'{x:.5f}').apply(str)
        spat_list['spats_long'] = spat_list['longitude'].apply(lambda x: f'{x:.5f}').apply(str)
        spat_list['spats'] = spat_list['spats_lat'] + ',' + spat_list['spats_long']
        #spat_list['spats'] = spat_list['latitude'].apply(lambda x: f'{x:.5f}').apply(str) + ',' + spat_list['longitude'].apply(lambda x: f'{x:.5f}').apply(str)
        spat_list['times'] = spat_list['date_time']
        spat_list['times'] = pd.to_datetime(spat_list['times'])
        spat_list['times'] = spat_list['times'].dt.strftime('%Y%m%d_%H%M%S')
    elif my_file == str('name'):
        while True:
            print('Specify a filepath to use to match location names: ')
            my_choice = input()
            if os.path.exists(my_choice):
                spat_list_names = pd.read_csv(my_choice,delimiter=',',index_col=False)
                locs = spat_list_names['location'].to_list()
            else:
                print('Not a file, try again...')
                continue
            break
    elif my_file == str('none'):
        print('No changes will be made to the location prefix')
    elif my_file == str('tone'):
        print('Tone will be search, continuing...')
    else:
        print('Sorry, could not find this directory.')
        print('')
        continue
    break

# Create a list of the speech results
vls = list(all_files.values())

#######################################################################################################
# Define the function that will compare site names to speech (e.g. OBBA)
#######################################################################################################
def match_names(site, speech, min_score=0):
    max_score = -1
    max_site = ''
    for x in site:
        fuzz_score = fuzz.ratio(x, speech)
        fuzz_partial_score = fuzz.partial_ratio(x, speech)
        fuzz_token_set_score = fuzz.token_set_ratio(x, speech)
        fuzz_token_sort_score = fuzz.token_sort_ratio(x, speech)
        fuzz_partial_token_set_score = fuzz.partial_token_set_ratio(x, speech)
        fuzz_partial_token_sort_score = fuzz.partial_token_sort_ratio(x, speech)
        fuzz_avg_score_list = [fuzz_score, fuzz_partial_score, fuzz_token_set_score,
                               fuzz_token_sort_score, fuzz_partial_token_set_score, fuzz_partial_token_sort_score]
        fuzz_avg_score = round(np.mean(fuzz_avg_score_list), 2)
        if (fuzz_avg_score > min_score) & (fuzz_avg_score > max_score):
            max_site = x
            max_score = fuzz_avg_score
    return (max_site, max_score)
#######################################################################################################

#######################################################################################################
# Define the function that will compare spatiotemporal information to speech (e.g. BU)
#######################################################################################################
def match_spatiotemporal(spat, speech, min_score=0):
    max_score = -1
    max_spat = ''
    for x in spat:
        fuzz_score = fuzz.ratio(x, speech)
        fuzz_partial_score = fuzz.partial_ratio(x, speech)
        fuzz_token_set_score = fuzz.token_set_ratio(x, speech)
        fuzz_token_sort_score = fuzz.token_sort_ratio(x, speech)
        fuzz_partial_token_set_score = fuzz.partial_token_set_ratio(x, speech)
        fuzz_partial_token_sort_score = fuzz.partial_token_sort_ratio(x, speech)
        fuzz_avg_score_list = [fuzz_score, fuzz_partial_score, fuzz_token_set_score,
                               fuzz_token_sort_score, fuzz_partial_token_set_score, fuzz_partial_token_sort_score]
        fuzz_avg_score = round(np.mean(fuzz_avg_score_list), 2)
        if (fuzz_score > min_score) & (fuzz_score > max_score):
            max_spat = x
            max_score = fuzz_score
    return (max_spat, max_score)
#######################################################################################################


# Append a list together of the matching results. Choose a minimum score threshold
while True:
   minscore = int(input('Choose a minimum score threshold between 0 and 100:'))
   if 0 <= minscore <= 100:
       break
   else:
       print('Try again')

# Create a new dictionary for results
all_files2 = {}
#
# Conduct the renaming of files and update the dictionaries
for key, value in all_files.items():
    if my_file == 'spat' or my_file == 'dttm':
        try:
            str_result = re.search('(?:(?<=north)|(?<=latitude)|(?<=999)).*$',value.lower()).group()
            str_result = re.sub('coordinates','',str_result)
            str_result = re.sub('longitude|west', ',', str_result)
            str_result = re.sub('latitude|north', '', str_result)
            str_result = re.sub('four|for', '4', str_result)
            str_result = re.sub('two|too|to', '2', str_result)
            str_result = re.sub('point', '-', str_result)
            str_result = re.sub('start|and|of', '', str_result)
            str_result = re.sub(' ', '', str_result)
            str_result = re.sub('-', '', str_result)
            str_result = re.sub('/', '', str_result)
            tm = spat_list['times'].to_list()
            su = spat_list['spats'].to_list()
            key_short = re.sub('^(.*?)_', '', os.path.splitext(os.path.basename(key))[0])
            # Run the function
            if my_file == 'spat':
                mst = match_spatiotemporal(su, value, minscore)
                if mst[1] >= minscore:
                    all_files2.update({key: [value, mst[0], mst[1]]})
                    print(key, mst[0], mst[1])
                else:
                    all_files2.update({key: [value, str('Score threshold not met')]})
            elif my_file == 'dttm':
                mst = match_spatiotemporal(key_short, tm, minscore)
                if mst[1] >= minscore:
                    print(value, mst[0], mst[1])
                    all_files2.update({key: [value, mst[0], mst[1]]})
                else:
                    all_files2.update({key: [value, str('Score threshold not met')]})
                    break
            else:
                print('failed')
        except Exception as e:
            print('Cant find a match using current parameters')
            all_files2.update({key: [value, str('Cant search string using current parameters')]})
    elif my_file == 'name':
        try:
            new_value = re.sub('four|for', '4', value)
            new_value = re.sub('two|too|to', '2', new_value)
            new_value = re.sub('one|One','1',new_value)
            new_value = re.sub('point', '-', new_value)
            new_value = re.sub('and|of', '', new_value)
            new_value = re.sub('station','-',new_value)
            new_value = re.sub('Station', '-', new_value)
            new_value = re.sub('\'','',new_value)
            new_value = re.sub('thats|it','',new_value)
            new_value = re.sub('roadside|Road|road|coordinates|Coordinates','', new_value)
            new_value = re.sub('number|point|count|Point|Count|Number','-',new_value)
            new_value = re.sub(r'^.*?time', '', new_value)
            new_value = re.sub(r'^.*?Time', '', new_value)
            new_value = re.sub(r'^.*?Square', '', new_value)
            new_value = re.sub(r'^.*?square', '', new_value)
            new_value = re.sub(r'^.*?', '', new_value)
            new_value = re.sub('dash','-',new_value)
            new_value = re.sub(' ','',new_value)
            new_value = new_value.upper()
            print(new_value)
            match = match_names(site=locs, speech=new_value, min_score=minscore)
            if match[1] >= minscore:
                okey = os.path.splitext(os.path.basename(key))[0]
                newkey = str(re.sub('^(.*?)_', str(match[0] + '_'), okey) + '.wav')
                newkeytype = str(os.path.join(os.path.dirname(key) + '/' + newkey))
                all_files2.update({key: [value, (str(match[0]), str(match[1])), newkeytype]})
            else:
                print('No match for ', value)
                break
        except Exception as e:
            print(e)
    elif my_file == 'none':
        all_files2.update({key: [value, ('Matched by user','100'), key]})
    elif my_file == 'tone':
        all_files2.update({key: [value, ('Tone matching', '100'), key]})
    else:
        print('No lookup table provided')
        break

# Update the file paths
output_val = {}

#Choose a duration
while True:
    print('Choose a number between 60 and 600 seconds (1 and 10 minutes).')
    task_length = int(input())
    if isinstance(task_length, int):
        print('')
        print('Finding start times...')
        print('')
    else:
        print('Choose a number between 0 and 600 seconds.')
        print('')
        continue
    break

all_files3 = {}
start_list = ['start', 'shark', 'search', 'stop', 'starting',
              'Start', 'Starts', 'Starting', 'sports', 'Sports', 'starts',
              'smoke', 'Smoke', 'important', 'Important', 'comfort',
              'Franklin','fort','Fort','downstairs','guard','star','Star','it\'s not','small','begin',
              'don\'t','sorts','Sorts','Begin',
              'people can\'t','shirts','Shirts','shirt','Shirt']

# Clip the files
for fpath, value in all_files.items():
    if fpath.endswith('wav') and not os.path.basename(fpath).startswith(tuple(pref)):
        try:
            my_audio = AudioSegment.from_file(fpath)
            task_length_ms = task_length * 1000
            dur = my_audio.duration_seconds
            print(fpath, dur)
            if dur < task_length:
                print('File too short for: ', fpath, '\n')
                all_files3.update({fpath: 'File too short for task length'})
            elif task_length <= dur <= task_length + 30:
                diff = int(my_audio.duration_seconds - task_length)
                chunk_time = datetime.strptime(str(re.compile('(?:.*?_){1}(.*)').split(fpath)[1].rsplit('.')[0]),'%Y%m%d_%H%M%S') + timedelta(seconds=diff)
                chunk_stamp = datetime.strftime(chunk_time, '%Y%m%d_%H%M%S')
                chunk_name = os.path.join(fpath.replace(str(re.compile('_(.*)').split(fpath)[1].rsplit('.')[0]),chunk_stamp))
                try:
                    print('Exporting audio from end ', fpath, '\n')
                    all_files3.update({fpath: chunk_name})
                    my_audio[-task_length_ms:].export(chunk_name, format='wav')
                except:
                    pass
            elif task_length + 30 <= dur <= 1800:
                chunk_length_ms = 1000
                chunks = make_chunks(my_audio, chunk_length_ms)
                file_clipped = False
                for i, chunk in enumerate(chunks):
                    r = sr.Recognizer()
                    s = sr.AudioFile(fpath)
                    with s as source:
                        ac = r.record(source, duration=2, offset=i)
                        try:
                            rc = r.recognize_google(ac, language='en-US')
                            if isinstance(rc,str) and any(map(rc.__contains__, start_list)):
                                chunk_time = datetime.strptime(str(re.compile('(?:.*?_){1}(.*)').split(fpath)[1].rsplit('.')[0]),'%Y%m%d_%H%M%S') + timedelta(seconds=i)
                                chunk_stamp = datetime.strftime(chunk_time, '%Y%m%d_%H%M%S')
                                chunk_name = os.path.join(fpath.replace(str(re.compile('_(.*)').split(fpath)[1].rsplit('.')[0]), chunk_stamp))
                                try:
                                    print('Success! Exporting', fpath, 'from', i)
                                    print('New name:', chunk_name, '\n')
                                    my_audio[i * 1000:(i * 1000) + task_length_ms].export(chunk_name, format='wav')
                                    all_files3.update({fpath:chunk_name})
                                    file_clipped = True
                                    break
                                except sr.UnknownValueError:
                                    print('Could not understand audio')
                                except sr.RequestError:
                                    print('Could not request results. check your internet connection')
                            elif isinstance(rc, str) and not any(map(rc.__contains__, start_list)):
                                pass
                            else:
                                pass
                        except Exception:
                            if i + task_length > dur:
                                chunk_time_n = datetime.strptime(str(re.compile('(?:.*?_){1}(.*)').split(fpath)[1].rsplit('.')[0]),'%Y%m%d_%H%M%S') + timedelta(seconds=i)
                                chunk_stamp_n = datetime.strftime(chunk_time_n, '%Y%m%d_%H%M%S')
                                chunk_name_n = os.path.join(fpath.replace(str(re.compile('_(.*)').split(fpath)[1].rsplit('.')[0]), chunk_stamp_n))
                                print('Couldnt find start but exporting', fpath, 'from', i)
                                print('New name:', chunk_name_n, '\n')
                                my_audio[i * 1000:(i * 1000) + task_length_ms].export(chunk_name_n, format='wav')
                                all_files3.update({fpath: chunk_name_n})
                                file_clipped = True
                                break
                            else:
                                pass
            else:
                print('noting happened for ', fpath, 'or duration did not meet criteria')
        except Exception as e:
            print(e)
    elif fpath.endswith('wav') and os.path.basename(fpath).startswith('ABMI') and my_file == 'tone':
        # DEALING WITH RIVERORKS RECORDINGS = SEPARATING ON THE TONE
        mytonef, sr = librosa.load(fpath, duration=30)
        # Calculate the peak amplitude
        peak_amplitude = np.max(np.abs(mytonef))
        # Convert peak amplitude to dBFS
        dBFS = 20 * np.log10(peak_amplitude)
        # Calculate the duration of the audio in seconds
        mytonedur = len(mytonef) / sr
        # Initialize lists to store results
        time_intervals = np.arange(0, mytonedur)
        dBFS_values = []
        # Calculate dBFS value at each second
        for t in time_intervals:
            start_sample = int(t * sr)
            end_sample = int((t + 1) * sr)
            segment = mytonef[start_sample:end_sample]
            segment_frequency = np.fft.fft(segment)
            segment_magnitude = np.abs(segment_frequency)
            frequency_bins = np.fft.fftfreq(len(segment), 1 / sr)
            indices = np.where(np.logical_and(frequency_bins >= 1600, frequency_bins <= 1700))[0]
            segment_peak_amplitude = np.max(segment_magnitude[indices])
            segment_dBFS = 20 * np.log10(segment_peak_amplitude)
            dBFS_values.append(segment_dBFS)
        threshold_db = 20
        breakpoints = []
        prev_dBFS = None
        # Print the results
        for t, dBFS_val in zip(time_intervals, dBFS_values):
            if prev_dBFS is not None and abs(dBFS_val - prev_dBFS) > threshold_db:
                breakpoints.append(t)
            prev_dBFS = dBFS_val
        print("Breakpoints (seconds):", breakpoints)
        max_breakpoint = int(max(breakpoints))
        # Show
        plt.scatter(time_intervals, dBFS_values)
        plt.plot(time_intervals, dBFS_values, "-")
        plt.xlabel('Time')
        plt.ylabel('dBFS')
        plt.title('Scatterplot with line for ',os.path.splitext(fpath)[0])
        # Re-load audio as segment and export using pydub
        mytonef = AudioSegment.from_file(fpath)
        # Re-arrange output to WildTrax standard ---- ###### ADD TIME IN HERE
        strfff = os.path.basename(os.path.splitext(fpath)[0]).split("_")
        outputtonebase = (strfff[0] + "-" + strfff[2] + '-' + strfff[3] + "_" + strfff[1])
        if mytonef.duration_seconds - max_breakpoint < task_length:
            print('Duration of clipped length is less than the task length for ', fpath, 'Re-formatting names anyways.')
            outputtonenoclip = (outputtonebase + '_noclip.wav')
            #mytonef.export(os.path.join(os.path.dirname(fpath), outputtonenoclip), format='wav')
            pass
        else:
            # Clip the audio at the max breakpoint
            outputtoneclip = (outputtonebase + '_clipped.wav')
            #mytonef[max_breakpoint * 1000:(max_breakpoint * 1000) + (task_length * 1000)].export(os.path.join(os.path.dirname(fpath), outputtoneclip), format='wav')
    else:
        pass
        print('Nothing happened for', fpath)

if my_file == "tone":
    pass
else:
    pd2 = pd.DataFrame(all_files2.items())
    pd2 = pd2.set_axis(['og_path', 'stuff'], axis=1)
    pd3 = pd.DataFrame(all_files3.items())
    pd3 = pd3.set_axis(['og_path', 'new_path'], axis=1)
    pdj = pd3.merge(pd2)
    pp1 = pdj['new_path'].to_list()
    pdj['loc'] = pdj['stuff'].astype(str).str.split(',', expand=True)[1].str.replace('(', '').str.replace("'",'').str.replace(' ', '')
    pp = pdj.apply(lambda x: pdj['new_path'].str.replace('LOCATION', str(x['loc'])), axis=1)
    pp2 = pd.Series(np.diag(pp), index=[pp.index, pp.columns]).to_list()
    print('Commit location decisions? Y/N?')
    decision = input()
    if decision == 'Y':
        for old, new in zip(pp1, pp2):
            if old == 'File too short for task length' and new == 'File too short for task length':
                pass
            elif old == new:
                print('File name ok')
            else:
                try:
                    os.rename(old, new)
                except Exception as e:
                    print(e)
        # Write the csv file
        while True:
            print('\nName your output log file:')
            csv_name = input() + str('.csv')
            pdj.to_csv(csv_name, sep=',', encoding='utf-8')
            break
    else:
        pass
