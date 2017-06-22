from __future__ import print_function
import matplotlib
matplotlib.use("ps")
import os
from milleniumcohort import create_config

import pickle
import pandas as pd

config = create_config('../config.yml')
config.create_data_paths()


file_path = config.merged_path
filenames = os.listdir(file_path)
filenames = [fn for fn in filenames if os.path.isfile(os.path.join(file_path,fn))]
filenames = [os.path.join(file_path,filename) for filename in filenames]
print('Processing {} files'.format(len(filenames)))



with open(config.model_file, 'rb') as f:
    model = pickle.load(f)

for fn in filenames:
    dataset = pd.read_csv(fn)
    dataset = dataset.set_index('timestamp')
    dataset.index = pd.to_datetime(dataset.index)
    X = dataset[config.hsmmconfig.column_names].as_matrix()
    prediction = model.predict(X, 0)
    dataset['state'] = prediction[1]
    fn_out = str(str(dataset['subset'][0]) + dataset['filename'][0])
    print("saving " + fn_out)
    dataset.to_csv(os.path.join(config.states_path, fn_out))
