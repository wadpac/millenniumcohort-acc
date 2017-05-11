from __future__ import print_function

import os
from UKMovementSensing import prepacc, tud

from milleniumcohort import create_config


config = create_config('config.yml')

# Read in Wearcodes
wearcodes = prepacc.load_wearcodes(config.wearcodes_path)


# Process accelerometer files
prepacc.process_data_onebyone(wearcodes, config.accelerometer_5sec_path, config.subset_path)

# Read the TUD file

print('Process annotations...')
annotations = tud.process_annotations(config.annotations_path)

# Join with wearcodes
print('Join wearcodes...')
annotations_codes = tud.join_wearcodes(wearcodes, annotations)

# Merge accelerometer data with diary
byName = annotations_codes.groupby(['binFile', 'day'])

for fn in os.listdir(config.subset_path):
    day = int(fn[-5])
    binFile = fn[2:-9]
    df = prepacc.load_acceleromater_data(os.path.join(config.subset_path, fn))

    df_annotated = tud.add_annotations(df, annotations_codes, binFile, day,
                                       on='slot', tz='Europe/London')

    nr_none = len(df_annotated[df_annotated['activity'] == None])
    if nr_none > 0:
        print('Warning: {} levels have no annotation'.format(nr_none))
    df_annotated.to_csv(os.path.join(config.merged_path, fn),
                        date_format='%Y-%m-%dT%H:%M:%S%z')