from __future__ import print_function
import matplotlib
matplotlib.use("ps")
import os
from milleniumcohort import create_config
from hsmm4acc import hsmm

import pandas as pd


config = create_config('config.yml')
config.create_data_paths()

# ## Load the data
train_path = config.merged_path
filenames = os.listdir(train_path)
filenames = [fn for fn in filenames if os.path.isfile(os.path.join(train_path,fn))]
filenames = [os.path.join(train_path,filename) for filename in filenames]
print('Processing {} files'.format(len(filenames)))

if config.hsmmconfig.batch_size == 0:
    # No batches, load everything in memory
    datasets = [pd.read_csv(fn) for fn in filenames]

    for i in range(len(datasets)):
        datasets[i] = datasets[i].set_index('timestamp')
        datasets[i].index = pd.to_datetime(datasets[i].index)

    # ## Prepare data for HSMM
    X_list = [d[config.hsmmconfig.column_names].as_matrix() for d in datasets]

    # ## Train HSMM

    #Note that with many iterations, the visualization becomes badly visible
    model = hsmm.train_hsmm(X_list, Nmax=config.hsmmconfig.Nmax,
                                        nr_resamples=config.hsmmconfig.nr_resamples,
                                        save_model_path=config.model_path,
                                        trunc=config.hsmmconfig.truncate, visualize=False, verbose=True)


    # ## Save the data with the states
    # Save the data including the states found. This labeled data serves as an input to the analyses.
    for i, dat in enumerate(datasets):
        dat['state'] = model.stateseqs[i]
        fn = str(str(dat['subset'][0]) + dat['filename'][0])
        dat.to_csv(os.path.join(config.states_path, fn))

else:
    # Train the model in batches of data
    model = hsmm.train_hsmm_all(filenames, config.hsmmconfig.column_names,
                                batchsize=config.hsmmconfig.batch_size,
                                Nmax=config.hsmmconfig.Nmax,
                                nr_resamples=config.hsmmconfig.nr_resamples,
                                save_model_path=config.model_path,
                                trunc=config.hsmmconfig.truncate, visualize=False, verbose=True)
    for filename in filenames:
        dat = pd.read_csv(filename)
        X = dat[config.hsmmconfig.column_names].as_matrix()
        prediction = model.predict(X, 0)
        dat['state'] = prediction[1]
        fn_out = str(str(dat['subset'][0]) + dat['filename'][0])
        print("saving "+fn_out)
        dat.to_csv(os.path.join(config.states_path, fn_out))



# ## Save the model
# NB: This removes the data from the model
import pickle
#Remove the data from the model
model.states_list = []

with open(config.model_file, 'wb') as f:
    pickle.dump(model, file=f)


# ## Save the config
from shutil import copyfile

copyfile('config.yml', config.config_file)




